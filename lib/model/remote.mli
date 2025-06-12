(** Describes a resource that is inlined or needs to be resolved. *)

type 'a t

val validate
  :  remote:Id.t Kane_util.Validation.v
  -> inline:'a Kane_util.Validation.v
  -> 'a t Kane_util.Validation.v

val normalize
  :  remote:(Id.t -> Yocaml.Data.t)
  -> inline:('a -> Yocaml.Data.t)
  -> 'a t
  -> Yocaml.Data.t

val resolve : (Id.t -> 'a option) -> 'a t -> 'a option
