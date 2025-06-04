class t ?title ?description () =
  object (self : #Intf.html_document)
    val title_value = title
    val description_value = description
    method title = title_value
    method description = description_value
    method set_title new_title = {<title_value = new_title>}
    method set_description new_desc = {<description_value = new_desc>}

    method meta_tags =
      Html_meta.
        [ from_option Fun.id ~name:"description" self#description
        ; make_opt ~name:"generator" ~content:"YOCaml"
        ]
      |> List.filter_map Fun.id
  end

let normalize doc =
  let open Yocaml.Data in
  let meta_tags = doc#meta_tags in
  record
    [ "title", option string doc#title
    ; "description", option string doc#description
    ; "meta", list_of Html_meta.normalize meta_tags
    ; Kane_util.as_opt_bool "title" doc#title
    ; Kane_util.as_opt_bool "description" doc#description
    ; Kane_util.as_list_bool "meta" meta_tags
    ]
;;
