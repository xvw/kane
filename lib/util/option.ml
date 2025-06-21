module Syntax = struct
  let ( let+ ) x f = Stdlib.Option.map f x
  let ( let* ) x f = Stdlib.Option.bind x f

  let ( and+ ) a b =
    match a, b with
    | Some a, Some b -> Some (a, b)
    | _ -> None
  ;;

  let ( and* ) = ( and+ )
end

module Infix = struct
  let ( <$> ) f x = Stdlib.Option.map f x
  let ( <$ ) x m = (fun _ -> x) <$> m
  let ( $> ) m x = (fun _ -> x) <$> m
  let ( >>= ) x f = Stdlib.Option.bind x f
  let ( =<< ) f x = x >>= f
  let ( >|= ) x f = f <$> x

  let ( <*> ) f x =
    match f with
    | Some f -> f <$> x
    | None -> None
  ;;

  let ( <|> ) a b =
    match a, b with
    | Some _, _ -> a
    | None, _ -> b
  ;;
end

include Infix
include Syntax

let unit x = () <$ x
let guard pred = if pred then Some () else None

let to_bool = function
  | Some _ -> true
  | None -> false
;;
