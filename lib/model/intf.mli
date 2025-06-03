(** A set of reusable signatures (such as interfaces or standard
    modules) that can be used to build archetypes of generated
    documents on demand. *)

(** Describes the metadata required to create an HTML page. In
    general, all data sources end up producing an expression of this
    type to be used as template provisions. *)
class type html_document = object
  (** Describes what will probably be used to characterise the page
      title (via [<title>]). *)
  method title : string
end
