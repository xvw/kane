open Kane_model

let dump subject =
  subject
  |> Yocaml.Data.(list_of string)
  |> Util_test.Dump.from (module Tag.Set)
;;

let%expect_test "tagset - 1" =
  [] |> dump;
  [%expect {| Ok: {"elements": [], "length": 0, "has_elements": false} |}]
;;

let%expect_test "tagset - 2" =
  [ "ocaml"; "haskell"; "types" ] |> dump;
  [%expect
    {|
    Ok: {"elements":
         [{"slug": "haskell", "text": "haskell"},
         {"slug": "ocaml", "text": "ocaml"}, {"slug": "types", "text": "types"}],
        "length": 3, "has_elements": true}
    |}]
;;

let%expect_test "tagset - 3" =
  [ "  hello "; "wOéèärl !!"; "OCaml and Haskell" ] |> dump;
  [%expect
    {|
    Ok: {"elements":
         [{"slug": "hello", "text": "hello"},
         {"slug": "ocaml-and-haskell", "text": "OCaml and Haskell"},
         {"slug": "wo-rl-bang-bang", "text": "wOéèärl !!"}],
        "length": 3, "has_elements": true}
    |}]
;;
