(** Describes the project configuration. *)

type t = private
  { main_title : string
  ; main_url : Url.t
  ; repository : Repository.t option
  ; branch : string
  ; owner : Identity.t option
  ; software_license : Link.t option
  ; content_license : Link.t option
  ; main_locale : string
  ; root : Yocaml.Path.t
  }

include Yocaml.Required.DATA_READABLE with type t := t

val normalize : t -> Yocaml.Data.t
val meta_tags : t -> Html_meta.t list
val with_root : Yocaml.Path.t -> t -> t
