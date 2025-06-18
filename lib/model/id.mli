(** Describes an identifier. *)

type t

val from_string : string -> t
val from_slug : Kane_util.Slug.t -> t
val from_path : Yocaml.Path.t -> t
val normalize : t -> Yocaml.Data.t
val validate : t Kane_util.Validation.v
val to_string : t -> string

module Map : Kane_util.Intf.MAP with type key = t
module Set : Kane_util.Intf.SET with type elt = t
module Map_of_set : Yocaml.Required.DATA_READABLE with type t = Set.t Map.t
