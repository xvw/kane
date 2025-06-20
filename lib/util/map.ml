module Make (O : Intf.ORDERED_TYPE) = struct
  include Stdlib.Map.Make (O)

  let validate_line on_subject =
    let open Yocaml.Data.Validation in
    record (fun b ->
      let open Validation in
      let+ key =
        required b [ "key"; "index"; "fst"; "k"; "first"; "0" ] O.validate
      and+ value =
        required b [ "value"; "val"; "snd"; "v"; "second"; "1" ] on_subject
      in
      key, value)
  ;;

  let to_set
        (type a b)
        (module S : Intf.SET with type t = a and type elt = b)
        folder
        map
    =
    fold (fun key value set -> S.add (folder key value) set) map S.empty
  ;;

  let to_deps f map =
    fold
      (fun key value set -> Yocaml.Deps.(concat @@ singleton (f key value)) set)
      map
      Yocaml.Deps.empty
  ;;

  let validate on_subject =
    let open Yocaml.Data.Validation in
    list_of (pair O.validate on_subject / validate_line on_subject)
    / record (fun fields ->
      Validation.required
        fields
        [ "all"; "elements"; "elts"; "map" ]
        (list_of (validate_line on_subject)))
    $ of_list
  ;;

  let normalize on_subject map =
    let open Yocaml.Data in
    record
      [ ( "elements"
        , map
          |> to_list
          |> list_of (fun (k, v) ->
            record [ "key", O.normalize k; "value", on_subject v ]) )
      ; "length", int (cardinal map)
      ; "has_elements", bool (not (is_empty map))
      ]
  ;;
end
