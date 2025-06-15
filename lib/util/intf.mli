module type ORDERED_TYPE = sig
  type t

  val compare : t -> t -> int
  val validate : t Validation.v
  val normalize : t -> Yocaml.Data.t
end

module type MAP = sig
  include Stdlib.Map.S

  val validate : 'a Validation.v -> 'a t Validation.v
  val normalize : ('a -> Yocaml.Data.t) -> 'a t -> Yocaml.Data.t
end

module type SET = sig
  include Stdlib.Set.S

  val validate : t Validation.v
  val normalize : t -> Yocaml.Data.t
end
