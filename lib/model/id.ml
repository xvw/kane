type t = Kane_util.Slug.t

let from_string x = x |> Kane_util.Slug.from
let from_slug x = from_string x

let validate =
  let open Yocaml.Data.Validation in
  string
  $ Kane_util.String.remove_first_char_when (function
    | '@' | ':' | '~' | '$' | '^' | '#' -> true
    | _ -> false)
  & Kane_util.String.ensure_not_blank
  & Yocaml.Slug.validate_string
;;

let normalize x =
  let open Yocaml.Data in
  string x
;;
