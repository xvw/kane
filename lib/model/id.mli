(** Describes an identifier. *)

type t

val from_string : string -> t
val from_slug : Kane_util.Slug.t -> t
val normalize : t -> Yocaml.Data.t
val validate : t Kane_util.Validation.v
