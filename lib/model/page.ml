class common
  ~title
  ?synopsis
  ?description
  ?(display_table_of_content = true)
  ?(tags = Tag.Set.empty)
  () =
  object (_ : #Intf.page)
    val title_value = title
    val synopsis_value = synopsis
    val description_value = description
    val tags_value = tags
    val display_table_of_content_value = display_table_of_content
    method title = title_value
    method synopsis = synopsis_value
    method description = description_value
    method tags = tags_value
    method display_table_of_content = display_table_of_content_value
  end

module Input = struct
  class page ~title ?synopsis ?description ?display_table_of_content ?tags () =
    object (_ : #Intf.page_input)
      inherit
        common ~title ?synopsis ?description ?display_table_of_content ?tags ()
    end

  type t = Intf.page_input

  let entity_name = "Page"
  let neutral = Yocaml.Metadata.required entity_name

  let validate =
    let open Yocaml.Data.Validation in
    record (fun f ->
      let open Kane_util.Validation in
      let+ title = required f [ "title"; "t" ] ensure_not_blank
      and+ synopsis = optional f [ "synopsis"; "long_desc" ] ensure_not_blank
      and+ description = optional f [ "desc"; "description" ] ensure_not_blank
      and+ tags = optional f [ "tags"; "keywords" ] Tag.Set.validate
      and+ display_table_of_content =
        optional
          f
          [ "with_toc"
          ; "toc"
          ; "table_of_content"
          ; "display_toc"
          ; "display_table_of_content"
          ]
          bool
      in
      new page ~title ?synopsis ?description ?display_table_of_content ?tags ())
  ;;
end

class page ~configuration ~source ~target ~link input =
  object (_ : #Intf.page_output)
    inherit
      common
        ~title:input#title
        ?synopsis:input#synopsis
        ?description:input#description
        ~display_table_of_content:input#display_table_of_content
        ~tags:input#tags
        ()

    inherit Backlinks.t ()
    val configuration_value = configuration
    val source_value = source
    val target_value = target
    val link_value = link
    val table_of_content_value = None
    val id_value = Id.from_path link
    method id = id_value
    method configuration = configuration_value
    method table_of_content = table_of_content_value
    method source_path = source_value
    method target_path = target_value
    method link_path = link_value
    method set_table_of_content new_toc = {<table_of_content_value = new_toc>}
  end

type t = Intf.page_output

let collect_links_of_meta _ = Id.Set.empty

let collect_links source =
  let open Yocaml.Eff in
  let+ meta, content =
    Yocaml_yaml.Eff.read_file_with_metadata ~on:`Source (module Input) source
  in
  ( content
    |> Kane_util.Markdown.collect_links
    |> Stdlib.List.map Id.from_string
    |> Id.Set.of_list
    |> Id.Set.union (collect_links_of_meta meta)
  , meta )
;;

let to_relation ~configuration ~source ~target ~link =
  let open Yocaml.Eff in
  let+ links, input_meta = collect_links source in
  let meta = new page ~configuration ~source ~target ~link input_meta in
  Relation.make
    ~title:meta#title
    ?synopsis:meta#synopsis
    ~link
    ~links:(Id.Set.remove meta#id links)
    meta#id
;;

let normalize (p : t) =
  Yocaml.Data.
    [ "title", string p#title
    ; "synopsis", option string p#synopsis
    ; "description", option string p#description
    ; "tags", Tag.Set.normalize p#tags
    ; "has_table_of_contents", bool p#display_table_of_content
    ; "table_of_contents", option string p#table_of_content
    ; "backlinks", list_of Relation.normalize p#backlinks
    ]
;;
