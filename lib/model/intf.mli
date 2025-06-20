(** A set of reusable signatures (such as interfaces or standard
    modules) that can be used to build archetypes of generated
    documents on demand. *)

class type normalizable = object
  method fieldset : (string * Yocaml.Data.t) list
end

class type with_table_of_contents = object ('self)
  method table_of_content : string option
  method set_table_of_content : string option -> 'self
end

class type backlinks = object ('self)
  method internal_links : Relation.t Id.Map.t
  method backlinks : Relation.t Id.Map.t
  method set_backlinks : Relation.t Id.Map.t -> 'self
  method set_internal_links : Relation.t Id.Map.t -> 'self
  method all : Relation.t Id.Map.t
end

class type with_backlinks = object ('self)
  method set : backlinks -> 'self
  method get : backlinks
end

class type page = object
  method title : string
  method synopsis : string option
  method description : string option
  method tags : Tag.Set.t
  method display_table_of_content : bool
end

(** Describe a regular page (as an input). *)
class type page_input = object
  inherit page
end

(** Describe a regular page (as an output). *)
class type page_output = object
  inherit page
  inherit with_table_of_contents
  method id : Id.t
  method configuration : Configuration.t
  method target_path : Yocaml.Path.t
  method source_path : Yocaml.Path.t
  method link_path : Yocaml.Path.t
  method links : with_backlinks
end
