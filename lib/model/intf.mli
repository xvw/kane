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
  method id : Id.t option
end

(** Describe a regular page (as an output). *)
class type page_output = object
  inherit page
  inherit with_table_of_contents
  method id : Id.t
  method configuration : Configuration.t
  method target_path : Yocaml.Path.t
  method source_path : Yocaml.Path.t
end

(** Describes the metadata required to create an HTML document. In
    general, all data sources end up producing an expression of this
    type to be used as template provisions. Usual archetype uses
    [html_document] to produce concrete page. *)
class type html_document = object ('self)
  inherit normalizable
  method title : string option
  method description : string option
  method meta_tags : Html_meta.t list
  method tags : Tag.Set.t
  method configuration : Configuration.t
  method set_title : string option -> 'self
  method set_description : string option -> 'self
  method set_configuration : Configuration.t -> 'self
  method set_tags : Tag.Set.t -> 'self
end
