(** A representation of internal or external URLs. *)

type t

val uri : t -> Uri.t
val https : string -> t
val is_internal : t -> bool
val is_external : t -> bool
val validate : t Kane_util.Validation.v
val normalize : t -> Yocaml.Data.t
val compact_name : t -> string
val resolve : t -> Yocaml.Path.t -> t
val on_path : (Yocaml.Path.t -> Yocaml.Path.t) -> t -> t
val to_string : t -> string
val host : t -> string
val path : t -> Yocaml.Path.t
val without_scheme : t -> string
