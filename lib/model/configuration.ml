type t = { main_title : string }

let validate =
  let open Yocaml.Data.Validation in
  let open Kane_util.Validation in
  record (fun fields ->
    let+ main_title =
      required fields [ "main_title"; "project_title"; "title" ] string
    in
    { main_title })
;;

let normalize { main_title } =
  let open Yocaml.Data in
  record [ "main_title", string main_title ]
;;
