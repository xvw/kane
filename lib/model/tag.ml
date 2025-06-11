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

module Set = struct
  include Stdlib.Set.Make (struct
      type nonrec t = t

      let compare = compare
    end)

  let empty = empty

  let validate =
    let open Yocaml.Data.Validation in
    list_of (string $ make) $ of_list
  ;;

  let normalize set =
    let open Yocaml.Data in
    record
      [ "all", list_of normalize (to_list set)
      ; "length", int (cardinal set)
      ; "has_tags", bool (not (is_empty set))
      ]
  ;;

  let meta_tags set =
    if is_empty set
    then []
    else (
      let content =
        set
        |> to_list
        |> Kane_util.String.concat_with (fun { repr; _ } -> repr) ", "
      in
      [ Html_meta.make ~name:"keywords" ~content ])
  ;;
end
