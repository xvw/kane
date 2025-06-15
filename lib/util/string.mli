(** Utilities for working with character strings. *)

(** {1 Utilities} *)

(** [concat_with f sep list] is [list |> List.map f |> String.concat sep]. *)
val concat_with : ('a -> string) -> string -> 'a list -> string

val to_list : string -> char list
val from_list : char list -> string
val char_at : string -> int -> char option
val remove_first_char_when : (char -> bool) -> string -> string

(** {1 Validators} *)

val ensure_not_blank : (string, string) Validation.t

(** {1 Map} *)

(** Map indexed over String. *)
module Map : Intf.MAP with type key = string
