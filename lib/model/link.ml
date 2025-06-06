type t =
  { title : string
  ; url : Url.t
  }

let make ?title url =
  let default = Url.compact_name url in
  let title = Option.value ~default title in
  { title; url }
;;

let compare a b =
  let c = String.compare a.title b.title in
  if Int.equal 0 c
  then (
    let a = Url.compact_name a.url in
    let b = Url.compact_name b.url in
    String.compare a b)
  else c
;;

let validate =
  let open Yocaml.Data.Validation in
  record (fun fields ->
    let open Kane_util.Validation in
    let+ url = required fields [ "href"; "url"; "target" ] Url.validate
    and+ title =
      optional
        fields
        [ "title"; "name" ]
        (string & Kane_util.String.ensure_not_blank)
    in
    make ?title url)
;;

let normalize { title; url } =
  let open Yocaml.Data in
  record [ "title", string title; "url", Url.normalize url ]
;;
