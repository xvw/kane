type t =
  { slug : Kane_util.Slug.t
  ; repr : string
  }

let make repr =
  let repr = String.trim repr in
  let slug = Kane_util.Slug.from repr in
  { repr; slug }
;;

let compare { slug = a; _ } { slug = b; _ } = String.compare a b

let validate =
  let open Yocaml.Data.Validation in
  string $ make
;;

let normalize { slug; repr } =
  let open Yocaml.Data in
  record [ "slug", string slug; "text", string repr ]
;;

module Set = Kane_util.Set.Make (struct
    type nonrec t = t

    let compare = compare
    let validate = validate
    let normalize = normalize
  end)

let meta_tags set =
  if Set.is_empty set
  then []
  else (
    let content =
      set
      |> Set.to_list
      |> Kane_util.String.concat_with (fun { repr; _ } -> repr) ", "
    in
    [ Html_meta.make ~name:"keywords" ~content ])
;;
