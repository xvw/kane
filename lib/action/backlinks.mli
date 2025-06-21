val prefetch
  :  (module Yocaml.Required.DATA_READABLE with type t = 'a)
  -> resolver:Kane_resolver.t
  -> source:Yocaml.Path.t
  -> id:Kane_model.Id.t
  -> (source:Yocaml.Path.t -> links:Kane_model.Backlinks.t -> 'a -> 'output)
  -> (unit, ('output * string) * Yocaml.Deps.t) Yocaml.Task.t
