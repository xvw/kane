let process_page ~(resolver : Kane_resolver.t) ~configuration layout source =
  let open Yocaml in
  let target = resolver#target#resolve_page source in
  let link = resolver#url#resolve_page source in
  let current_id = Kane_model.Id.from_path link in
  Action.Dynamic.write_file_with_metadata
    target
    Task.(
      Pipeline.track_files resolver#common_deps
      >>> Backlinks.prefetch
            (module Kane_model.Page.Input)
            ~resolver
            ~source
            ~id:current_id
            (fun ~source ~links input ->
               new Kane_model.Page.t
                 ~configuration
                 ~source
                 ~target
                 ~link
                 ~links
                 input)
      >>> Dynamic.on_static (Markdown.to_html_with_resolution ())
      >>> Dynamic.on_static layout)
;;

let all layout ~(resolver : Kane_resolver.t) ~configuration =
  Yocaml.Action.batch
    ~only:`Files
    ~where:Kane_util.markdown_ext
    resolver#source#pages
    (process_page ~resolver ~configuration layout)
;;
