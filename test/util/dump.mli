val validation
  :  (Format.formatter -> 'a -> unit)
  -> 'a Yocaml.Data.Validation.validated_value
  -> unit

val normalization
  :  ('a -> Yocaml.Data.t)
  -> 'a Yocaml.Data.Validation.validated_value
  -> unit

val from : (module Intf.DUMP) -> Yocaml.Data.t -> unit
