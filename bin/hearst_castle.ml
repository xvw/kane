let program (resolver : Kane_resolver.t) () =
  let open Yocaml in
  let open Eff in
  let cache = resolver#state#cache in
  let* configuration = return Kane_model.Configuration.neutral in
  Action.restore_cache ~on:`Source cache
  >>= Kane_action.Pages.index_links ~resolver ~configuration
  >>= Action.store_cache ~on:`Source cache
;;

let () =
  let source = Yocaml.Path.rel [ "hearst_castle" ] in
  let resolver = new Kane_resolver.t ~source () in
  Yocaml_eio.run ~level:`Debug (program resolver)
;;
