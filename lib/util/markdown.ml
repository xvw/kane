let get_label label =
  match Stdlib.String.split_on_char ':' label with
  | ("id" | "ref" | "kane") :: [ label ] -> Some label
  | _ -> None
;;

let get_link_id = function
  | `Inline (link, _) ->
    Stdlib.Option.bind (link |> Cmarkit.Link_definition.dest) (fun (l, _) ->
      get_label l)
  | `Ref _ -> None
;;

let inline _ set = function
  | Cmarkit.Inline.Autolink (auto, _) ->
    let label, _ = Cmarkit.Inline.Autolink.link auto in
    (match get_label label with
     | Some label -> Cmarkit.Folder.ret (label :: set)
     | None -> Cmarkit.Folder.default)
  | Cmarkit.Inline.Link (link, _) ->
    let reference = Cmarkit.Inline.Link.reference link in
    (match get_link_id reference with
     | Some label -> Cmarkit.Folder.ret (label :: set)
     | None -> Cmarkit.Folder.default)
  | _ -> Cmarkit.Folder.default
;;

let collect_links content =
  let doc = Cmarkit.Doc.of_string ~strict:false content in
  let folder = Cmarkit.Folder.make ~inline () in
  Cmarkit.Folder.fold_doc folder [] doc
;;
