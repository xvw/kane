(** Utilities for working with list. *)

(** {1 Utilities} *)

(** [List.fold_left] but maintaining the cursor. *)
val fold_lefti : (int -> 'acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc
