let ensure_not_blank =
  Yocaml.Data.Validation.where
    ~pp:Format.pp_print_string
    ~message:(fun _ -> "Can't be blank")
    (fun s -> not (Stdlib.String.equal "" s))
;;

(* TODO: maybe to be improved. *)
let to_list x = x |> Stdlib.String.to_seq |> Stdlib.List.of_seq

let from_list =
  Stdlib.List.fold_left (fun buf x -> buf ^ Stdlib.String.make 1 x) ""
;;

let char_at str i =
  try Some (Stdlib.String.get str i) with
  | Invalid_argument _ -> None
;;

let remove_first_char_when pred string =
  match char_at string 0 with
  | Some c ->
    if pred c
    then (
      let len = Stdlib.String.length string in
      Stdlib.String.sub string 1 (len - 1))
    else string
  | None -> string
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
  List.fold_lefti
    (fun i acc x ->
       let sep = if Int.equal i 0 then "" else sep in
       acc ^ sep ^ f x)
    ""
    list
;;
