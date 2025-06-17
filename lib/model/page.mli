(** Describes a set of metadata for regular page. *)

module Input : Yocaml.Required.DATA_READABLE

(** Write a page. *)

type t

module Dump : sig
  include Yocaml.Required.DATA_READABLE

  val to_string : t -> string
  val id : t -> Id.t
  val title : t -> string
  val synopsis : t -> string option
  val link : t -> Yocaml.Path.t
  val links : t -> Id.Set.t

  val visit
    :  configuration:Configuration.t
    -> source:Yocaml.Path.t
    -> target:Yocaml.Path.t
    -> link:Yocaml.Path.t
    -> t Yocaml.Eff.t
end
