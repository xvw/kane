let prefetch
      (type a)
      (module Input : Yocaml.Required.DATA_READABLE with type t = a)
      ~(resolver : Kane_resolver.t)
      ~source
      ~id
      configure
  =
  let backlinks = resolver#state#resolve_backlink id in
  let open Yocaml in
  let open Task in
  Yocaml_yaml.Pipeline.read_file_with_metadata (module Input) source
  &&& when_
        (Pipeline.file_exists backlinks)
        (Pipeline.read_file_as_metadata
           (module Sexp.Provider.Canonical)
           (module Kane_model.Backlinks)
           backlinks)
        (const (new Kane_model.Backlinks.t ()))
  >>| fun ((input, content), links) ->
  let output = configure ~source ~links input in
  let resolve links =
    Kane_model.Id.Map.to_deps (fun id _ -> resolver#state#resolve_id id) links
  in
  let dynamic_deps =
    Deps.concat (resolve links#backlinks) (resolve links#internal_links)
  in
  (output, content), dynamic_deps
;;
