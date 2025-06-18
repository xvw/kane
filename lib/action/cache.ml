let with_cache ~(resolver : Kane_resolver.t) callback =
  let open Yocaml.Eff in
  let cache_file = resolver#state#cache in
  Yocaml.Action.restore_cache ~on:`Source cache_file
  >>= callback
  >>= Yocaml.Action.store_cache ~on:`Source cache_file
;;
