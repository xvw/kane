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
  class page
    ?id
    ~title
    ?synopsis
    ?description
    ?display_table_of_content
    ?tags
    () =
    object (_ : #Intf.page_input)
      inherit
        common ~title ?synopsis ?description ?display_table_of_content ?tags ()

      val id_value = id
      method id = id_value
    end

  type t = Intf.page_input

  let entity_name = "Page"
  let neutral = Yocaml.Metadata.required entity_name

  let validate =
    let open Yocaml.Data.Validation in
    record (fun f ->
      let open Kane_util.Validation in
      let+ id = optional f [ "id"; "ident"; "identifier"; "uid" ] Id.validate
      and+ title = required f [ "title"; "t" ] ensure_not_blank
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
      new page
        ?id
        ~title
        ?synopsis
        ?description
        ?display_table_of_content
        ?tags
        ())
  ;;
end

let id_of target input =
  let default = target |> Id.from_path in
  Option.value ~default input#id
;;

class t ~configuration ~source ~target input =
  object (_ : #Intf.page_output)
    inherit
      common
        ~title:input#title
        ?synopsis:input#synopsis
        ?description:input#description
        ~display_table_of_content:input#display_table_of_content
        ~tags:input#tags
        ()

    val configuration_value = configuration
    val source_value = source
    val target_value = target
    val table_of_content_value = None
    val id_value = id_of target input
    method id = id_value
    method configuration = configuration_value
    method table_of_content = table_of_content_value
    method source_path = source_value
    method target_path = target_value
    method set_table_of_content new_toc = {<table_of_content_value = new_toc>}
  end

(* let visit ~source ~target cache = *)
(*   let open Yocaml.Eff in *)
(*   let* meta, content = *)
(*     Yocaml_yaml.Eff.read_file_with_metadata ~on:`Source (module Input) source *)
(*   in *)
(*   assert false *)
(* ;; *)
