class t :
  ?backlinks:Relation.t Id.Map.t
  -> ?internal_links:Relation.t Id.Map.t
  -> unit
  -> Intf.with_backlinks

val validate : t Kane_util.Validation.v
val normalize : t -> Yocaml.Data.t
val dump : t -> string
