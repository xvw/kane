(** Describes the metadata of an HTML document (which can be linked to
    each page generated). *)

class t :
  ?title:string
  -> ?description:string
  -> ?configuration:Configuration.t
  -> ?tags:Tag.Set.t
  -> unit
  -> Intf.html_document

val normalize : #Intf.html_document -> Yocaml.Data.t
