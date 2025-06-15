(** Tools for composing validations more easily. *)

type ('a, 'b) t = 'a -> 'b Yocaml.Data.Validation.validated_value
type 'a v = (Yocaml.Data.t, 'a) t

(** An alternative required validator that can deal with multiple fields. *)
val required
  :  (string * Yocaml.Data.t) list
  -> string list
  -> 'a v
  -> 'a Yocaml.Data.Validation.validated_record

(** An alternative optional validator that can deal with multiple fields. *)
val optional
  :  (string * Yocaml.Data.t) list
  -> string list
  -> 'a v
  -> 'a option Yocaml.Data.Validation.validated_record

(** An alternative optional validator that can deal with multiple fields. *)
val optional_or
  :  default:'a
  -> (string * Yocaml.Data.t) list
  -> string list
  -> 'a v
  -> 'a Yocaml.Data.Validation.validated_record

val ensure_not_blank : string v
