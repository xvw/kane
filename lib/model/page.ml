module Input = struct
  class t ?id ~title ?synopsis ?description ?(tags = Tag.Set.empty) () =
    object (_ : #Intf.page_input)
      val title_value = title
      val synopsis_value = synopsis
      val description_value = description
      val tags_value = tags
      val id_value = id
      method title = title_value
      method synopsis = synopsis_value
      method description = description_value
      method tags = tags_value
      method id = id_value
    end

  let validate =
    let open Yocaml.Data.Validation in
    record (fun f ->
      let open Kane_util.Validation in
      let+ id = optional f [ "id"; "ident"; "identifier"; "uid" ] Id.validate
      and+ title = required f [ "title"; "t" ] ensure_not_blank
      and+ synopsis = optional f [ "synopsis"; "long_desc" ] ensure_not_blank
      and+ description = optional f [ "desc"; "description" ] ensure_not_blank
      and+ tags = optional f [ "tags"; "keywords" ] Tag.Set.validate in
      new t ?id ~title ?synopsis ?description ?tags ())
  ;;
end
