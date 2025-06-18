type t =
  { id : Id.t
  ; title : string
  ; synopsis : string option
  ; link : Yocaml.Path.t
  ; links : Id.Set.t
  }

let make ~title ?synopsis ~link ?(links = Id.Set.empty) id =
  { title; synopsis; link; links; id }
;;

let id { id; _ } = id
let title { title; _ } = title
let synopsis { synopsis; _ } = synopsis
let link { link; _ } = link
let links { links; _ } = links
let entity_name = "Relation"
let neutral = Yocaml.Metadata.required entity_name

let validate =
  let open Yocaml.Data.Validation in
  record (fun fields ->
    let+ id = required fields "id" Id.validate
    and+ title = required fields "title" string
    and+ synopsis = optional fields "synopsis" string
    and+ link = required fields "link" Kane_util.Path.validate
    and+ links =
      optional_or ~default:Id.Set.empty fields "links" Id.Set.validate
    in
    { id; title; synopsis; link; links })
;;

let normalize { id; title; synopsis; link; links } =
  let open Yocaml.Data in
  record
    [ "id", Id.normalize id
    ; "title", string title
    ; "synopsis", option string synopsis
    ; "link", Kane_util.Path.normalize link
    ; "links", Id.Set.normalize links
    ]
;;

let dump x =
  x |> normalize |> Yocaml.Data.to_sexp |> Yocaml.Sexp.Canonical.to_string
;;
