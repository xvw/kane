type t =
  { references : (Yocaml.Path.t * string * string option) Id.Map.t
  ; backlinks : Id.Set.t Id.Map.t
  ; collisions : Kane_util.Path.Set.t Id.Map.t
  }

let empty =
  { references = Id.Map.empty
  ; backlinks = Id.Map.empty
  ; collisions = Id.Map.empty
  }
;;

let add_backlinks back_id links cache =
  let backlinks =
    Id.Set.fold
      (fun id backlinks ->
         Id.Map.update
           id
           (function
             | None -> Some (Id.Set.singleton back_id)
             | Some x -> Some (Id.Set.add back_id x))
           backlinks)
      links
      cache.backlinks
  in
  { cache with backlinks }
;;

let visit ~id ~path ~title ?synopsis ?(links = Id.Set.empty) cache =
  let backlinks = Id.Set.remove id links in
  match Id.Map.find_opt id cache.references with
  | None ->
    { cache with
      references = Id.Map.add id (path, title, synopsis) cache.references
    }
    |> add_backlinks id backlinks
  | Some (p, _, _) when Yocaml.Path.equal p path ->
    cache |> add_backlinks id backlinks
  | Some (p, _, _) ->
    let collide x =
      let x = Option.value ~default:Kane_util.Path.Set.empty x in
      let c = Kane_util.Path.Set.of_list [ p; path ] in
      Some (Kane_util.Path.Set.union x c)
    in
    { cache with collisions = Id.Map.update id collide cache.collisions }
;;

let collisions { collisions; _ } =
  match Id.Map.cardinal collisions with
  | 0 -> None
  | _ -> Some collisions
;;

let missing_references { references; backlinks; _ } =
  let s =
    Id.Map.fold
      (fun _id backlinks acc ->
         Id.Set.fold
           (fun id acc ->
              match Id.Map.find_opt id references with
              | None -> Id.Set.add id acc
              | Some _ -> acc)
           backlinks
           acc)
      backlinks
      Id.Set.empty
  in
  match Id.Set.cardinal s with
  | 0 -> None
  | _ -> Some s
;;

let references { references; _ } = references
let backlinks { backlinks; _ } = backlinks
let reference_by_id id cache = cache |> references |> Id.Map.find_opt id

let backlinks_by_id id cache =
  cache |> backlinks |> Id.Map.find_opt id |> Option.value ~default:Id.Set.empty
;;
