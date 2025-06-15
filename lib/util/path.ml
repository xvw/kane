module O = struct
  type t = Yocaml.Path.t

  let compare = Yocaml.Path.compare
  let normalize path = Yocaml.Data.string (Yocaml.Path.to_string path)

  let validate =
    let open Yocaml.Data.Validation in
    string $ Yocaml.Path.from_string
  ;;
end

module Map = Map.Make (O)
module Set = Set.Make (O)
