let create_link_table ~(resolver : Kane_resolver.t) ~configuration source =
  let open Yocaml in
  let target = resolver#target#resolve_page source in
  let link = resolver#url#resolve_page target in
  let id = Kane_model.Id.from_path link in
  let task () =
    let open Eff in
    let+ dump =
      Kane_model.Page.Dump.visit ~configuration ~source ~target ~link
    in
    Kane_model.Page.Dump.to_string dump
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
