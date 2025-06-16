let visit ~(resolver : Kane_resolver.t) ~configuration links_cache =
  let open Yocaml.Eff in
  Yocaml.Action.fold
    ~only:`Files
    ~where:Kane_util.markdown_ext
    ~state:links_cache
    resolver#source#pages
    (fun source state cache ->
       let open Yocaml.Eff in
       let target = resolver#target#resolve_page source in
       let+ new_state =
         Kane_model.Page.visit ~configuration ~source ~target state
       in
       cache, new_state)
    Yocaml.Cache.empty
  >|= snd
;;
