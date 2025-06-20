let get_label label =
  match Stdlib.String.split_on_char ':' label with
  | ("id" | "ref" | "kane") :: [ label ] -> Some label
  | _ -> None
;;

let get_link_id = function
  | `Inline (link, _) ->
    Stdlib.Option.bind (link |> Cmarkit.Link_definition.dest) (fun (l, m) ->
      get_label l |> Stdlib.Option.map (fun label -> link, m, label))
  | `Ref _ -> None
;;

let collect_inline _ set = function
  | Cmarkit.Inline.Autolink (auto, _) ->
    let label, _ = Cmarkit.Inline.Autolink.link auto in
    (match get_label label with
     | Some label -> Cmarkit.Folder.ret (label :: set)
     | None -> Cmarkit.Folder.default)
  | Cmarkit.Inline.Link (link, _) ->
    let reference = Cmarkit.Inline.Link.reference link in
    (match get_link_id reference with
     | Some (_, _, label) -> Cmarkit.Folder.ret (label :: set)
     | None -> Cmarkit.Folder.default)
  | _ -> Cmarkit.Folder.default
;;

let collect_links content =
  let doc = Cmarkit.Doc.of_string ~strict:false content in
  let folder = Cmarkit.Folder.make ~inline:collect_inline () in
  Cmarkit.Folder.fold_doc folder [] doc
;;

let make_reference ?elt_desc ~url ~desc () =
  let title =
    let open Option.Infix in
    elt_desc
    <|> ((fun desc ->
           desc
           |> Cmarkit.Block_line.list_of_string
           |> Stdlib.List.map (fun k -> "", k))
         <$> desc)
  in
  let link_def =
    ( Cmarkit.Link_definition.make ?title ~dest:(url, Cmarkit.Meta.make ()) ()
    , Cmarkit.Meta.make () )
  in
  `Inline link_def
;;

let make_full_link ~meta ~url ~title ~desc =
  let elt = Cmarkit.Inline.Text (title, Cmarkit.Meta.make ()) in
  let reference = make_reference ~url ~desc () in
  Cmarkit.Inline.Link (reference |> Cmarkit.Inline.Link.make elt, meta)
;;

let map_link ~meta ~link ~url ~title ~desc elt =
  let elt_desc = Cmarkit.Link_definition.title link in
  let elt_title = Cmarkit.Inline.Link.text elt in
  let selected_title =
    let r = elt_title |> Cmarkit.Inline.to_plain_text ~break_on_soft:false in
    Stdlib.(String.concat "\n" (List.map (String.concat "") r))
    |> Stdlib.String.trim
  in
  let reference = make_reference ?elt_desc ~url ~desc () in
  let inline =
    if Stdlib.String.equal selected_title ""
    then Cmarkit.Inline.Text (title, Cmarkit.Meta.make ())
    else elt_title
  in
  Cmarkit.Inline.Link (reference |> Cmarkit.Inline.Link.make inline, meta)
;;

let resolve_links resolver doc =
  let resolve_inline _map = function
    | Cmarkit.Inline.Autolink (auto, meta) ->
      let label, _ = Cmarkit.Inline.Autolink.link auto in
      (match Stdlib.Option.bind (get_label label) resolver with
       | Some (url, title, desc) ->
         let l = make_full_link ~meta ~url ~title ~desc in
         Cmarkit.Mapper.ret l
       | None -> Cmarkit.Mapper.default)
    | Cmarkit.Inline.Link (link_elt, _) ->
      let reference = Cmarkit.Inline.Link.reference link_elt in
      (match
         Stdlib.Option.bind (get_link_id reference) (fun (l, m, label) ->
           label |> resolver |> Stdlib.Option.map (fun t -> l, m, t))
       with
       | Some (link, meta, (url, title, desc)) ->
         let l = map_link ~meta ~link ~url ~title ~desc link_elt in
         Cmarkit.Mapper.ret l
       | None -> Cmarkit.Mapper.default)
    | _ -> Cmarkit.Mapper.default
  in
  let mapper = Cmarkit.Mapper.make ~inline:resolve_inline () in
  Cmarkit.Mapper.map_doc mapper doc
;;
