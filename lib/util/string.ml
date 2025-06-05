let ensure_not_blank =
  Yocaml.Data.Validation.where
    ~pp:Format.pp_print_string
    ~message:(fun _ -> "Can't be blank")
    (fun s -> not (Stdlib.String.equal "" s))
;;

module Map = struct
  include Stdlib.Map.Make (Stdlib.String)

  let validate on_subject =
    let open Yocaml.Data.Validation in
    list_of
      (pair string on_subject
       / record (fun b ->
         let+ key =
           Validation.required
             b
             [ "key"; "index"; "fst"; "k"; "first"; "0" ]
             (string & ensure_not_blank)
         and+ value =
           Validation.required
             b
             [ "value"; "val"; "snd"; "v"; "second"; "1" ]
             on_subject
         in
         key, value))
    $ of_list
  ;;

  let normalize on_subject map =
    let open Yocaml.Data in
    map
    |> to_list
    |> list_of (fun (k, v) -> record [ "key", string k; "value", on_subject v ])
  ;;
end

let concat_with f sep list =
  let res, _ =
    List.fold_left
      (fun (acc, i) x ->
         let sep = if Int.equal i 0 then "" else sep in
         acc ^ sep ^ f x, succ i)
      ("", 0)
      list
  in
  res
;;
