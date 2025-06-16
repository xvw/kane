type t

val empty : t

val visit
  :  id:Id.t
  -> path:Yocaml.Path.t
  -> title:string
  -> ?synopsis:string
  -> ?links:Id.Set.t
  -> t
  -> t

val collisions : t -> Kane_util.Path.Set.t Id.Map.t option
val missing_references : t -> Id.Set.t option
val references : t -> (Yocaml.Path.t * string * string option) Id.Map.t
val backlinks : t -> Id.Set.t Id.Map.t

val reference_by_id
  :  Id.t
  -> t
  -> (Yocaml.Path.t * string * string option) option

val backlinks_by_id : Id.t -> t -> Id.Set.t
