val all
  :  (Kane_model.Page.t * string, 'a * string) Yocaml.Task.t
  -> resolver:Kane_resolver.t
  -> configuration:Kane_model.Configuration.t
  -> Yocaml.Action.t
