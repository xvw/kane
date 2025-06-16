type p := Yocaml.Path.t

class t : ?source:p -> ?target:p -> unit -> object
  method source : < root : p ; content : p ; pages : p >
  method target : < root : p ; pages : p ; resolve_page : p -> p >
end
