(** A representation of an external repository. *)

type t

val validate : t Kane_util.Validation.v
val normalize : t -> Yocaml.Data.t
val resolve : Yocaml.Path.t -> t -> Url.t
val blob : ?branch:string -> Yocaml.Path.t -> t -> Url.t
