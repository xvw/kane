val collect_links : string -> string list

val resolve_links
  :  (string -> (string * string * string option) option)
  -> Cmarkit.Doc.t
  -> Cmarkit.Doc.t
