type t = string

val default_mapping : (char * string) list

val from
  :  ?mapping:(char * string) list
  -> ?separator:char
  -> ?unknown_char:char
  -> string
  -> t

val from_path : Yocaml.Path.t -> t
