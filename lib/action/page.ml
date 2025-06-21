let read_page
      ~(resolver : Kane_resolver.t)
      ~configuration
      ~source
      ~target
      ~link
      ~id
  =
  let backlinks = resolver#state#resolve_backlink id in
  let open Yocaml in
  let open Task in
  let open Kane_model in
  Yocaml_yaml.Pipeline.read_file_with_metadata (module Page.Input) source
  &&& when_
        (Pipeline.file_exists backlinks)
        (Pipeline.read_file_as_metadata
           (module Sexp.Provider.Canonical)
           (module Backlinks)
           backlinks)
        (const (new Kane_model.Backlinks.t ()))
  >>| fun ((input, content), links) ->
  let page = new Page.t ~configuration ~source ~target ~link ~links input in
  let resolve links =
    Id.Map.to_deps (fun id _ -> resolver#state#resolve_id id) links
  in
  let dynamic_deps =
    Deps.concat (resolve links#backlinks) (resolve links#internal_links)
  in
  (page, content), dynamic_deps
;;

let process_page ~(resolver : Kane_resolver.t) ~configuration source =
  let open Yocaml in
  let target = resolver#target#resolve_page source in
  let link = resolver#url#resolve_page source in
  let current_id = Kane_model.Id.from_path link in
  Action.Dynamic.write_file_with_metadata
    target
    Task.(
      Pipeline.track_files resolver#common_deps
      >>> read_page
            ~resolver
            ~configuration
            ~source
            ~target
            ~link
            ~id:current_id
      >>> Dynamic.on_static (Markdown.to_html_with_resolution ()))
;;

let all ~(resolver : Kane_resolver.t) ~configuration =
  Yocaml.Action.batch
    ~only:`Files
    ~where:Kane_util.markdown_ext
    resolver#source#pages
    (process_page ~resolver ~configuration)
;;
