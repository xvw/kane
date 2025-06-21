let to_html_with_resolution () =
  let open Yocaml.Task in
  second (Yocaml_cmarkit.to_doc ~strict:false ())
  >>> second Yocaml_cmarkit.table_of_contents
  >>| (fun (meta, (toc, content)) -> meta#set_table_of_content toc, content)
  >>> lift (fun (meta, content) ->
    let resolver key =
      let key = Kane_model.Id.from_string key in
      meta#links#get#all
      |> Kane_model.Id.Map.find_opt key
      |> Option.map (fun rel ->
        ( rel |> Kane_model.Relation.link |> Yocaml.Path.to_string
        , rel |> Kane_model.Relation.title
        , rel |> Kane_model.Relation.synopsis ))
    in
    meta, Kane_util.Markdown.resolve_links resolver content)
  >>> second (Yocaml_cmarkit.from_doc_to_html ~safe:false ())
;;
