type ('a, 'b) t = 'a -> 'b Yocaml.Data.Validation.validated_value
type 'a v = (Yocaml.Data.t, 'a) t

let required fields alt validator =
  let open Yocaml.Data.Validation in
  let rec loop ?field = function
    | [] ->
      let field = Stdlib.Option.value ~default:"unknown_field" field in
      Error (Yocaml.Nel.singleton @@ Missing_field { field })
    | field :: xs ->
      (match required fields field validator with
       | Ok x -> Ok x
       | Error _ -> loop ~field xs)
  in
  loop alt
;;

let optional fields alt validator =
  let open Yocaml.Data.Validation in
  let rec loop = function
    | [] -> Ok None
    | field :: xs ->
      (match optional fields field validator with
       | Ok None -> loop xs
       | Ok x -> Ok x
       | Error _ as error -> error)
  in
  loop alt
;;

let optional_or ~default fields alt validator =
  let open Yocaml.Data.Validation in
  let rec loop = function
    | [] -> Ok default
    | field :: xs ->
      (match optional fields field validator with
       | Ok None -> loop xs
       | Ok (Some x) -> Ok x
       | Error _ as error -> error)
  in
  loop alt
;;
