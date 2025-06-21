let program (resolver : Kane_resolver.t) () =
  let open Yocaml in
  let open Eff in
  let* configuration = Kane_action.Configuration.fetch ~resolver in
  Kane_action.Cache.with_cache
    ~resolver
    (Kane_action.State.indexation ~resolver ~configuration
     >=> Kane_action.Page.all ~resolver ~configuration)
;;

let () =
  let source = Yocaml.Path.rel [ "hearst_castle" ] in
  let resolver = new Kane_resolver.t ~source () in
  Yocaml_eio.run ~level:`Debug (program resolver)
;;
