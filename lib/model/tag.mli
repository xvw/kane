(** Describes tags (for indexing). *)

type t

val normalize : t -> Yocaml.Data.t
val validate : t Kane_util.Validation.v

module Set : Kane_util.Intf.SET with type elt = t

val meta_tags : Set.t -> Html_meta.t list
