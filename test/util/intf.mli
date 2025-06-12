module type DUMP = sig
  type t

  val normalize : t -> Yocaml.Data.t
  val validate : t Kane_util.Validation.v
end
