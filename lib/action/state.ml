let create_id_table ~(resolver : Kane_resolver.t) ~configuration source =
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
    (resolver#state#resolve_id id)
    Task.(
      Pipeline.track_files resolver#common_deps
      >>> Pipeline.track_file source
      >>> from_effect task)
;;

let index_ids ~(resolver : Kane_resolver.t) ~configuration =
  let open Yocaml in
  Action.batch
    ~only:`Files
    ~where:Kane_util.markdown_ext
    resolver#source#pages
    (create_id_table ~resolver ~configuration)
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
        resolver#state#ids
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
      >>> Pipeline.track_file resolver#state#ids
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
  let create_state set current_relation =
    let backlink_files =
      set
      |> Kane_model.Id.Set.to_list
      |> Stdlib.List.map resolver#state#resolve_id
    in
    let internal_link_files =
      current_relation
      |> Kane_model.Relation.links
      |> Kane_model.Id.Set.to_list
      |> Stdlib.List.map resolver#state#resolve_id
    in
    let* internal_links =
      List.traverse
        (fun x ->
           read_file_as_metadata
             ~on:`Source
             (module Sexp.Provider.Canonical)
             (module Kane_model.Relation)
             x)
        internal_link_files
    in
    let+ backlinks =
      List.traverse
        (fun x ->
           read_file_as_metadata
             ~on:`Source
             (module Sexp.Provider.Canonical)
             (module Kane_model.Relation)
             x)
        backlink_files
    in
    let link_state =
      new Kane_model.Backlinks.t
        ~backlinks:(Kane_model.Relation.to_map backlinks)
        ~internal_links:(Kane_model.Relation.to_map internal_links)
        ()
    in
    ( Kane_model.Backlinks.dump link_state
    , Deps.from_list (backlink_files @ internal_link_files) )
  in
  Action.batch_list
    store
    (fun (current_id, set) ->
       let id_file = resolver#state#resolve_id current_id in
       let target = resolver#state#resolve_backlink current_id in
       Action.Dynamic.write_file
         target
         Task.(
           Pipeline.track_files resolver#common_deps
           >>> Pipeline.track_files [ resolver#state#backlinks_map ]
           >>> Pipeline.read_file_as_metadata
                 (module Sexp.Provider.Canonical)
                 (module Kane_model.Relation)
                 id_file
           >>> from_effect ~has_dynamic_dependencies:true (create_state set)))
    cache
;;

let indexation ~(resolver : Kane_resolver.t) ~configuration =
  let open Yocaml.Eff in
  index_ids ~resolver ~configuration
  >=> index_backlinks ~resolver
  >=> index_each_backlinks ~resolver
;;
