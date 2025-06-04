module String = String
module Validation = Validation

let as_opt_bool field value =
  let field = "has_" ^ field in
  let result =
    match value with
    | None -> false
    | Some _ -> true
  in
  field, Yocaml.Data.bool result
;;

let as_list_bool field value =
  let field = "has_" ^ field in
  let result =
    match value with
    | [] -> false
    | _ :: _ -> true
  in
  field, Yocaml.Data.bool result
;;
