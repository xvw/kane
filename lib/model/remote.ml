type 'a t =
  | Remote of Kane_util.Slug.t
  | Inline of 'a

let validate ~remote ~inline =
  let open Yocaml.Data.Validation in
  (remote $ fun x -> Remote x) / (inline $ fun x -> Inline x)
;;

let normalize ~remote ~inline =
  let open Yocaml.Data in
  sum (function
    | Remote slug -> "remote", remote slug
    | Inline x -> "inline", inline x)
;;

let resolve resolver = function
  | Inline x -> Some x
  | Remote slug -> resolver slug
;;
