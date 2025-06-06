(** A link is an URL associated to a title. *)

type t

val make : ?title:string -> Url.t -> t
val compare : t -> t -> int
val validate : t Kane_util.Validation.v
val normalize : t -> Yocaml.Data.t
