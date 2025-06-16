(** Describes a set of metadata for regular page. *)

module Input : Yocaml.Required.DATA_READABLE

(** Write a page. *)

class t :
  configuration:Configuration.t
  -> source:Yocaml.Path.t
  -> target:Yocaml.Path.t
  -> #Intf.page_input
  -> Intf.page_output
