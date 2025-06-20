class t :
  ?backlinks:Relation.t Id.Map.t
  -> ?internal_links:Relation.t Id.Map.t
  -> unit
  -> Intf.backlinks

class attached : ?backlinks:t -> unit -> Intf.with_backlinks

include Yocaml.Required.DATA_READABLE with type t := t

val normalize : t -> Yocaml.Data.t
val dump : t -> string
