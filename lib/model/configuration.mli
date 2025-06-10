(** Describes the project configuration. *)

type t

val validate : t Kane_util.Validation.v
val normalize : t -> Yocaml.Data.t
val meta_tags : t -> Html_meta.t list
