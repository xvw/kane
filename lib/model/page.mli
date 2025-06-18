(** Describes a set of metadata for regular page. *)

module Input : Yocaml.Required.DATA_READABLE

(** Write a page. *)

type t

val visit
  :  configuration:Configuration.t
  -> source:Yocaml.Path.t
  -> target:Yocaml.Path.t
  -> link:Yocaml.Path.t
  -> ((Id.t * string * string option) * Id.Set.t) Yocaml.Eff.t
