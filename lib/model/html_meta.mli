(** Describes an html metadata, characterised by the [<meta>] tag. *)

type t

(** [make ~name ~content] creates a meta tag. *)
val make : name:string -> content:string -> t

(** [make_opt ~name ~content] creates an optional meta tag. *)
val make_opt : name:string -> content:string -> t option

(** [from_option f ~name opt] map an option in the meta tag. *)
val from_option : ('a -> string) -> name:string -> 'a option -> t option

(** [from_list f ~name l] constructs an optional meta by merging the
    various elements of the list. *)
val from_list : ('a -> string) -> name:string -> 'a list -> t option

(** Converts a meta into YOCaml data. *)
val normalize : t -> Yocaml.Data.t

(** Lift an option ot a list of meta tags. *)
val map_option : ('a -> 'b list) -> 'a option -> 'b list
