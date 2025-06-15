module Make (O : Intf.ORDERED_TYPE) = struct
  include Stdlib.Set.Make (O)

  let validate =
    let open Yocaml.Data.Validation in
    list_of O.validate
    / record (fun fields ->
      Validation.required
        fields
        [ "all"; "elements"; "elts"; "set" ]
        (list_of O.validate))
    $ of_list
  ;;

  let normalize set =
    let open Yocaml.Data in
    record
      [ "elements", set |> to_list |> list_of O.normalize
      ; "length", int (cardinal set)
      ; "has_elements", bool (not (is_empty set))
      ]
  ;;
end
