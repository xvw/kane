(** A representation of an external repository. *)

type t

val validate : t Kane_util.Validation.v
val normalize : t -> Yocaml.Data.t
