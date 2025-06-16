(** [has_field is_empty field opt] compute the [has_field] using [is_empty]. *)
val has_field : ('a -> bool) -> string -> 'a -> string * Yocaml.Data.t

(** [as_opt_bool field opt] compute the [has_field] from an option. *)
val as_opt_bool : string -> 'a option -> string * Yocaml.Data.t

(** [as_list_bool field opt] compute the [has_field] from a list. *)
val as_list_bool : string -> 'a list -> string * Yocaml.Data.t

(** Convert an arbitrary data-expression to a s-expression. *)
val to_sexp : Yocaml.Data.t -> Yocaml.Sexp.t

(** Return [true] if the file has one of the given extension. *)
val one_of_ext : string list -> Yocaml.Path.t -> bool

(** Check if a filepath has a markdown extension. *)
val markdown_ext : Yocaml.Path.t -> bool
