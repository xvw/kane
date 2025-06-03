(** Utilities for working with character strings. *)

(** [concat_with f sep list] is [list |> List.map f |> String.concat sep]. *)
val concat_with : ('a -> string) -> string -> 'a list -> string
