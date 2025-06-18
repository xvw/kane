let fetch ~(resolver : Kane_resolver.t) =
  Yocaml_otoml.Eff.read_file_as_metadata
    (module Kane_model.Configuration)
    ~on:`Source
    resolver#source#configuration
;;
