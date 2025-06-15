class t
  ?title
  ?description
  ?(configuration = Configuration.neutral)
  ?(tags = Tag.Set.empty)
  () =
  object (self : #Intf.html_document)
    val title_value = title
    val description_value = description
    val configuration_value = configuration
    val tags_value = tags
    method title = title_value
    method description = description_value
    method configuration = configuration_value
    method tags = tags_value
    method set_title new_title = {<title_value = new_title>}
    method set_description new_desc = {<description_value = new_desc>}
    method set_configuration new_conf = {<configuration_value = new_conf>}
    method set_tags new_tags = {<tags_value = new_tags>}

    method meta_tags =
      (Html_meta.
         [ from_option Fun.id ~name:"description" self#description
         ; make_opt ~name:"generator" ~content:"YOCaml"
         ]
       |> List.filter_map Fun.id)
      @ Configuration.meta_tags configuration
      @ Tag.meta_tags tags

    method fieldset =
      let meta_tags = self#meta_tags in
      let open Yocaml.Data in
      [ "title", option string self#title
      ; "description", option string self#description
      ; "meta", list_of Html_meta.normalize meta_tags
      ; "tags", Tag.Set.normalize self#tags
      ; Kane_util.as_opt_bool "title" self#title
      ; Kane_util.as_opt_bool "description" self#description
      ; Kane_util.as_list_bool "meta" meta_tags
      ]
  end

let normalize doc =
  let open Yocaml.Data in
  record doc#fieldset
;;
