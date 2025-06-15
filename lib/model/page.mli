(** Describes a set of metadata for regular page. *)

module Input : sig
  (** Read a page. *)

  class t :
    ?id:Id.t
    -> title:string
    -> ?synopsis:string
    -> ?description:string
    -> ?display_table_of_content:bool
    -> ?tags:Tag.Set.t
    -> unit
    -> Intf.page_input

  val validate : t Kane_util.Validation.v
end

(** Write a page. *)

class t :
  configuration:Configuration.t
  -> source:Yocaml.Path.t
  -> target:Yocaml.Path.t
  -> #Intf.page_input
  -> Intf.page_output
