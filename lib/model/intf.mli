(** A set of reusable signatures (such as interfaces or standard
    modules) that can be used to build archetypes of generated
    documents on demand. *)

class type normalizable = object
  method fieldset : (string * Yocaml.Data.t) list
end

(** Describe a regular page. *)
class type page_input = object
  method title : string
  method id : Id.t option
  method synopsis : string option
  method description : string option
  method tags : Tag.Set.t
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
