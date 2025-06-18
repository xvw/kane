type target_resolver = Intf.target
type p := Yocaml.Path.t
type i := Kane_model.Id.t

class t : ?source:p -> ?target:p -> ?web_folder:p -> unit -> object
  method bin : p
  method common_deps : p list

  method state :
    < parent : p
    ; cache : p
    ; links : p
    ; backlinks : p
    ; backlinks_map : p
    ; resolve_id : p -> i -> p
    ; resolve_link : i -> p
    ; resolve_backlink : i -> p >

  method source : < parent : p ; content : p ; configuration : p ; pages : p >
  method target : target_resolver
  method url : target_resolver
end
