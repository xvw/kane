type t = string

let default_mapping =
  [ '+', "plus"
  ; '&', "and"
  ; '$', "dollar"
  ; '%', "percent"
  ; '&', "and"
  ; '<', "less"
  ; '>', "greater"
  ; '|', "or"
  ; '@', "at"
  ; '#', "hash"
  ; '!', "bang"
  ; '?', "question"
  ; '*', ""
  ; '(', ""
  ; ')', ""
  ; '[', ""
  ; ']', ""
  ; '}', ""
  ; '{', ""
  ; '`', ""
  ]
;;

let from ?(mapping = default_mapping) = Yocaml.Slug.from ~mapping
