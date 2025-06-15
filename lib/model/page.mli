(** Describes a set of metadata for regular page. *)

module Input : sig
  (** Read a page. *)

  class t :
    ?id:Id.t
    -> title:string
    -> ?synopsis:string
    -> ?description:string
    -> ?tags:Tag.Set.t
    -> unit
    -> Intf.page_input

  val validate : t Kane_util.Validation.v
end
