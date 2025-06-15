let ensure_not_blank = Validation.ensure_not_blank

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

module Map = Map.Make (struct
    type t = string

    let compare = Stdlib.String.compare
    let validate = Yocaml.Data.Validation.(string & ensure_not_blank)
    let normalize = Yocaml.Data.string
  end)

let concat_with f sep list =
  List.fold_lefti
    (fun i acc x ->
       let sep = if Int.equal i 0 then "" else sep in
       acc ^ sep ^ f x)
    ""
    list
;;
