let create_link_table ~(resolver : Kane_resolver.t) ~configuration source =
  let open Yocaml in
  let target = resolver#target#resolve_page source in
  let link = resolver#url#resolve_page target in
  let id = Kane_model.Id.from_path link in
  let task () =
    let open Eff in
    let open Kane_model in
    let+ rel = Page.to_relation ~configuration ~source ~target ~link in
    Relation.dump rel
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

let index_backlinks ~(resolver : Kane_resolver.t) =
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
           (module Kane_model.Relation))
        links
    in
    Stdlib.List.fold_left
      (fun store rel ->
         let open Kane_model in
         Id.Set.fold
           (fun id map ->
              Id.Map.update
                id
                (function
                  | None -> Some (Id.Set.singleton (Relation.id rel))
                  | Some set -> Some (Id.Set.add (Relation.id rel) set))
                map)
           (Relation.links rel)
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

let index_each_backlinks ~(resolver : Kane_resolver.t) cache =
  let open Yocaml in
  let open Yocaml.Eff in
  let* store =
    read_file_as_metadata
      ~on:`Source
      (module Sexp.Provider.Canonical)
      (module Kane_model.Id.Map_of_set)
      resolver#state#backlinks_map
  in
  let store = Kane_model.Id.Map.to_list store in
  let create_state set () =
    let files =
      set
      |> Kane_model.Id.Set.to_list
      |> Stdlib.List.map resolver#state#resolve_link
    in
    let+ s =
      List.traverse
        (fun x ->
           let* () = logf "aie: %a" Yocaml.Path.pp x in
           read_file_as_metadata
             ~on:`Source
             (module Sexp.Provider.Canonical)
             (module Kane_model.Relation)
             x)
        files
    in
    ( s
      |> Data.list_of Kane_model.Relation.normalize
      |> Data.to_sexp
      |> Sexp.Canonical.to_string
    , Deps.from_list files )
  in
  Action.batch_list
    store
    (fun (current_id, set) ->
       let target = resolver#state#resolve_backlink current_id in
       Action.Dynamic.write_file
         target
         Task.(
           Pipeline.track_files resolver#common_deps
           >>> Pipeline.track_file resolver#state#backlinks_map
           >>> from_effect ~has_dynamic_dependencies:true (create_state set)))
    cache
;;

let indexation ~(resolver : Kane_resolver.t) ~configuration =
  let open Yocaml.Eff in
  index_links ~resolver ~configuration
  >=> index_backlinks ~resolver
  >=> index_each_backlinks ~resolver
;;
