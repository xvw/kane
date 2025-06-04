(** A set of reusable signatures (such as interfaces or standard
    modules) that can be used to build archetypes of generated
    documents on demand. *)

(** Describes the metadata required to create an HTML page. In
    general, all data sources end up producing an expression of this
    type to be used as template provisions. *)
class type html_document = object ('self)
  (** Describes what will probably be used to characterise the page
      title (via [<title>]). *)
  method title : string option

  (** Describes the description of a document. Used to compute
      [<meta>]. *)
  method description : string option

  (** Return the list of [<meta>]. *)
  method meta_tags : Html_meta.t list

  (** Return the object with a new title. *)
  method set_title : string option -> 'self

  (** Return the object with a new description. *)
  method set_description : string option -> 'self
end
