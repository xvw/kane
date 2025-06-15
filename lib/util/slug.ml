type t = string

let default_mapping =
  [ '+', "plus"
  ; '&', "and"
  ; '$', "dollar"
  ; '%', "percent"
  ; '&', "and"
  ; '<', "less"
  ; '>', "greater"
  ; '|', "or"
  ; '@', "at"
  ; '#', "hash"
  ; '!', "bang"
  ; '?', "question"
  ; '*', ""
  ; '(', ""
  ; ')', ""
  ; '[', ""
  ; ']', ""
  ; '}', ""
  ; '{', ""
  ; '`', ""
  ]
;;

let from ?(mapping = default_mapping) = Yocaml.Slug.from ~mapping

let from_path path =
  let p =
    match Yocaml.Path.to_pair path with
    | `Rel, [] -> "rel"
    | `Root, [] -> "root"
    | _ -> Yocaml.Path.to_string path
  in
  p |> from
;;
