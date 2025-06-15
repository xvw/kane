type t =
  { references : Yocaml.Path.t Id.Map.t
  ; backlinks : Id.Set.t Id.Map.t
  ; collisions : Kane_util.Path.Set.t Id.Map.t
  }

let empty =
  { references = Id.Map.empty
  ; backlinks = Id.Map.empty
  ; collisions = Id.Map.empty
  }
;;

let add_backlinks id backlinks cache =
  let backlinks = Id.Set.of_list backlinks in
  { cache with
    backlinks =
      Id.Map.update
        id
        (function
          | None -> Some backlinks
          | Some u -> Some (Id.Set.union u backlinks))
        cache.backlinks
  }
;;

let visit ~id ~path ~backlinks cache =
  match Id.Map.find_opt id cache.references with
  | None ->
    { cache with references = Id.Map.add id path cache.references }
    |> add_backlinks id backlinks
  | Some p when Yocaml.Path.equal p path -> cache |> add_backlinks id backlinks
  | Some p ->
    let collide x =
      let x = Option.value ~default:Kane_util.Path.Set.empty x in
      let c = Kane_util.Path.Set.of_list [ p; path ] in
      Some (Kane_util.Path.Set.union x c)
    in
    { cache with collisions = Id.Map.update id collide cache.collisions }
;;

(* let to_sexp { references; backlinks; collisions } = *)
(*   let open Yocaml.Sexp in *)
(*   node [ *)

(*   ] *)
(* ;; *)
