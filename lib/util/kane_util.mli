(** Set of utilities to make it easier to build the generator. *)

module String = String
module Validation = Validation

(** [as_opt_bool field opt] compute the [has_field] from an option. *)
val as_opt_bool : string -> 'a option -> string * Yocaml.Data.t

(** [as_list_bool field opt] compute the [has_field] from a list. *)
val as_list_bool : string -> 'a list -> string * Yocaml.Data.t
