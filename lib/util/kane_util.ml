module Intf = Intf
module Validation = Validation
module Set = Set
module Map = Map
module String = String
module List = List
module Option = Option
module Slug = Slug
module Path = Path
module Markdown = Markdown

let mk_has_field field = "has_" ^ field

let has_field is_empty field value =
  let result = not (is_empty value) in
  mk_has_field field, Yocaml.Data.bool result
;;

let as_opt_bool field opt = has_field Stdlib.Option.is_none field opt
let as_list_bool field value = has_field Stdlib.List.is_empty field value

let rec to_sexp = function
  | Yocaml.Data.Null -> Yocaml.Sexp.node []
  | Yocaml.Data.Bool x -> Yocaml.Sexp.atom (string_of_bool x)
  | Yocaml.Data.Int x -> Yocaml.Sexp.atom (string_of_int x)
  | Yocaml.Data.Float x -> Yocaml.Sexp.atom (string_of_float x)
  | Yocaml.Data.String x -> Yocaml.Sexp.atom x
  | Yocaml.Data.List x ->
    Yocaml.Sexp.node
      (Stdlib.List.concat_map
         (function
           | Yocaml.Data.Null -> []
           | x -> [ to_sexp x ])
         x)
  | Yocaml.Data.Record xs ->
    Yocaml.Sexp.node
      (Stdlib.List.concat_map
         (fun (k, v) ->
            match v with
            | Yocaml.Data.Null -> []
            | v -> [ Yocaml.Sexp.(node [ atom k; to_sexp v ]) ])
         xs)
;;
