module String = String
module Validation = Validation

let mk_has_field field = "has_" ^ field

let has_field is_empty field value =
  let result = not (is_empty value) in
  mk_has_field field, Yocaml.Data.bool result
;;

let as_opt_bool field opt = has_field Option.is_none field opt
let as_list_bool field value = has_field Stdlib.List.is_empty field value
