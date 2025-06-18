(** Describes a set of metadata for regular page. *)

module Input : Yocaml.Required.DATA_READABLE

(** Write a page. *)

type t

val to_relation
  :  configuration:Configuration.t
  -> source:Yocaml.Path.t
  -> target:Yocaml.Path.t
  -> link:Yocaml.Path.t
  -> Relation.t Yocaml.Eff.t

val normalize : t -> (string * Yocaml.Data.t) list
