include Yocaml.Required.DATA_READABLE

val make
  :  title:string
  -> ?synopsis:string
  -> link:Yocaml.Path.t
  -> ?links:Id.Set.t
  -> Id.t
  -> t

val dump : t -> string
val id : t -> Id.t
val title : t -> string
val synopsis : t -> string option
val link : t -> Yocaml.Path.t
val links : t -> Id.Set.t
val normalize : t -> Yocaml.Data.t
val to_map : t list -> t Id.Map.t
