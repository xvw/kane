module Make (O : Intf.ORDERED_TYPE) = struct
  include Stdlib.Map.Make (O)

  let validate on_subject =
    let open Yocaml.Data.Validation in
    list_of
      (pair O.validate on_subject
       / record (fun b ->
         let open Validation in
         let+ key =
           required b [ "key"; "index"; "fst"; "k"; "first"; "0" ] O.validate
         and+ value =
           required b [ "value"; "val"; "snd"; "v"; "second"; "1" ] on_subject
         in
         key, value))
    $ of_list
  ;;

  let normalize on_subject map =
    let open Yocaml.Data in
    map
    |> to_list
    |> list_of (fun (k, v) ->
      record [ "key", O.normalize k; "value", on_subject v ])
  ;;
end
