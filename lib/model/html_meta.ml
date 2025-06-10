type t =
  { name : string
  ; content : string
  }

let make ~name ~content = { name; content }
let make_opt ~name ~content = Some (make ~name ~content)

let from_option f ~name =
  Option.map (fun content -> make ~name ~content:(f content))
;;

let from_list f ~name = function
  | [] -> None
  | xs -> make_opt ~name ~content:(Kane_util.String.concat_with f ", " xs)
;;

let normalize { name; content } =
  let open Yocaml.Data in
  record [ "name", string name; "content", string content ]
;;

let map_option f = function
  | None -> []
  | Some x -> f x
;;
