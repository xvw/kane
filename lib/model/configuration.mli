(** Describes the project configuration. *)

include Yocaml.Required.DATA_READABLE

val normalize : t -> Yocaml.Data.t
val meta_tags : t -> Html_meta.t list
val with_root : Yocaml.Path.t -> t -> t
