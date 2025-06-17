let create_link_table ~(resolver : Kane_resolver.t) ~configuration source =
  let open Yocaml in
  let target = resolver#target#resolve_page source in
  let link = resolver#url#resolve_page target in
  let id = Kane_model.Id.from_path link in
  let task () =
    let open Eff in
    let open Kane_model.Page in
    let+ dump = Dump.visit ~configuration ~source ~target ~link in
    Dump.to_string dump
  in
  Action.Static.write_file
    (resolver#state#resolve_link id)
    Task.(
      Pipeline.track_files resolver#common_deps
      >>> Pipeline.track_file source
      >>> from_effect task)
;;

let index_links ~(resolver : Kane_resolver.t) ~configuration =
  let open Yocaml in
  Action.batch
    ~only:`Files
    ~where:Kane_util.markdown_ext
    resolver#source#pages
    (create_link_table ~resolver ~configuration)
;;

let create_backlinks ~(resolver : Kane_resolver.t) =
  let open Yocaml in
  let traverse_links () =
    let open Eff in
    let* links =
      read_directory
        ~on:`Source
        ~only:`Files
        ~where:Kane_util.csexp_ext
        resolver#state#links
    in
    let+ links =
      List.traverse
        (read_file_as_metadata
           ~on:`Source
           (module Sexp.Provider.Canonical)
           (module Kane_model.Page.Dump))
        links
    in
    Stdlib.List.fold_left
      (fun store dump ->
         let open Kane_model in
         Id.Set.fold
           (fun id map ->
              Id.Map.update
                id
                (function
                  | None -> Some (Id.Set.singleton (Page.Dump.id dump))
                  | Some set -> Some (Id.Set.add (Page.Dump.id dump) set))
                map)
           (Page.Dump.links dump)
           store)
      Kane_model.Id.Map.empty
      links
  in
  Action.write_static_file
    resolver#state#backlinks_map
    Task.(
      Pipeline.track_files resolver#common_deps
      >>> Pipeline.track_file resolver#state#links
      >>> from_effect traverse_links
      >>| fun x ->
      x
      |> Kane_model.(Id.Map.normalize Id.Set.normalize)
      |> Data.to_sexp
      |> Sexp.Canonical.to_string)
;;
