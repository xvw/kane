(** Modestly represents an email address *)

type t

val from_address : (Emile.address, t) Kane_util.Validation.t
val validate : t Kane_util.Validation.v
val normalize : t -> Yocaml.Data.t
