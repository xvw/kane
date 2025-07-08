val source : ?default:Yocaml.Path.t -> unit -> Yocaml.Path.t Cmdliner.Term.t
val target : ?default:Yocaml.Path.t -> unit -> Yocaml.Path.t Cmdliner.Term.t
val port : ?default:int -> unit -> int Cmdliner.Term.t

val log_level
  :  ?default:([ `App | `Debug | `Error | `Info | `Warning ] as 'a)
  -> unit
  -> 'a Cmdliner.Term.t
