class t : ?backlinks:Relation.t list -> unit -> object ('a)
  val backlinks_value : Relation.t list
  method backlinks : Relation.t list
  method set_backlinks : Relation.t list -> 'a
end
