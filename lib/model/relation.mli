include Yocaml.Required.DATA_READABLE

val dump : t -> string
val id : t -> Id.t
val title : t -> string
val synopsis : t -> string option
val link : t -> Yocaml.Path.t
val links : t -> Id.Set.t

val from_page
  :  configuration:Configuration.t
  -> source:Yocaml.Path.t
  -> target:Yocaml.Path.t
  -> link:Yocaml.Path.t
  -> t Yocaml.Eff.t

val normalize : t -> Yocaml.Data.t
