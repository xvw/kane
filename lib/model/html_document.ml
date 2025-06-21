let normalize (h : #Intf.html_document) =
  let meta_tags = h#meta_tags in
  let open Yocaml.Data in
  record
    [ "title", option string h#title
    ; "description", option string h#description
    ; "meta", list_of Html_meta.normalize meta_tags
    ; Kane_util.as_opt_bool "title" h#title
    ; Kane_util.as_opt_bool "description" h#description
    ; Kane_util.as_list_bool "meta" meta_tags
    ]
;;
