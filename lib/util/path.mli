val normalize : Yocaml.Path.t -> Yocaml.Data.t
val validate : Yocaml.Path.t Validation.v

module Map : Intf.MAP with type key = Yocaml.Path.t
module Set : Intf.SET with type elt = Yocaml.Path.t
