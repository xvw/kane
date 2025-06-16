(** Set of utilities to make it easier to build the generator. *)

module Intf = Intf
module Validation = Validation
module Set = Set
module Map = Map
module String = String
module List = List
module Option = Option
module Slug = Slug
module Path = Path
module Markdown = Markdown

include module type of Util (** @inline *)
