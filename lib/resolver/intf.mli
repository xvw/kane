open Yocaml

class type target = object
  method parent : Path.t
  method pages : Path.t
  method resolve_page : Path.t -> Path.t
end
