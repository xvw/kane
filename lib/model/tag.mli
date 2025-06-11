(** Describes tags (for indexing). *)

type t

val normalize : t -> Yocaml.Data.t
val validate : t Kane_util.Validation.v

module Set : sig
  (** Describes tag set (for indexing). *)

  type t

  val empty : t
  val validate : t Kane_util.Validation.v
  val normalize : t -> Yocaml.Data.t
  val meta_tags : t -> Html_meta.t list
end
