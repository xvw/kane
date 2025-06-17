type t = Kane_util.Slug.t

let trim x =
  x
  |> Kane_util.String.remove_first_char_when (function
    | '@' | ':' | '~' | '$' | '^' | '#' -> true
    | _ -> false)
  |> String.trim
;;

let from_string x = x |> trim |> Kane_util.Slug.from
let from_slug x = from_string x

let from_path x =
  x |> Yocaml.Path.remove_extension |> Kane_util.Slug.from_path |> from_slug
;;

let validate =
  let open Yocaml.Data.Validation in
  string $ trim
  & Kane_util.String.ensure_not_blank
  & Yocaml.Slug.validate_string
;;

let normalize x =
  let open Yocaml.Data in
  string x
;;

module O = struct
  type nonrec t = t

  let compare = String.compare
  let normalize = normalize
  let validate = validate
end

module Set = Kane_util.Set.Make (O)
module Map = Kane_util.Map.Make (O)

let to_string x = x
