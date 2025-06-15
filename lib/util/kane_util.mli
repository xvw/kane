(** Set of utilities to make it easier to build the generator. *)

module Intf = Intf
module Validation = Validation
module Set = Set
module Map = Map
module String = String
module List = List
module Option = Option
module Slug = Slug

(** [has_field is_empty field opt] compute the [has_field] using [is_empty]. *)
val has_field : ('a -> bool) -> string -> 'a -> string * Yocaml.Data.t

(** [as_opt_bool field opt] compute the [has_field] from an option. *)
val as_opt_bool : string -> 'a option -> string * Yocaml.Data.t

(** [as_list_bool field opt] compute the [has_field] from a list. *)
val as_list_bool : string -> 'a list -> string * Yocaml.Data.t
