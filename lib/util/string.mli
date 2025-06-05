(** Utilities for working with character strings. *)

(** {1 Utilities} *)

(** [concat_with f sep list] is [list |> List.map f |> String.concat sep]. *)
val concat_with : ('a -> string) -> string -> 'a list -> string

(** {1 Validators} *)

val ensure_not_blank : (string, string) Validation.t

(** {1 Map} *)

(** Map indexed over String. *)
module Map : sig
  include Stdlib.Map.S with type key = string

  val validate : 'a Validation.v -> 'a t Validation.v
  val normalize : ('a -> Yocaml.Data.t) -> 'a t -> Yocaml.Data.t
end
