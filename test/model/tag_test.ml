open Kane_model

let dump subject =
  subject
  |> Yocaml.Data.(list_of string)
  |> Tag.Set.validate
  |> Util_test.Dump.normalization Tag.Set.normalize
;;

let%expect_test "tagset - 1" =
  [] |> dump;
  [%expect {| Ok: {"all": [], "length": 0, "has_tags": false} |}]
;;

let%expect_test "tagset - 2" =
  [ "ocaml"; "haskell"; "types" ] |> dump;
  [%expect
    {|
    Ok: {"all":
         [{"slug": "haskell", "text": "haskell"},
         {"slug": "ocaml", "text": "ocaml"}, {"slug": "types", "text": "types"}],
        "length": 3, "has_tags": true}
    |}]
;;

let%expect_test "tagset - 3" =
  [ "  hello "; "wOéèärl !!"; "OCaml and Haskell" ] |> dump;
  [%expect
    {|
    Ok: {"all":
         [{"slug": "hello", "text": "hello"},
         {"slug": "ocaml-and-haskell", "text": "OCaml and Haskell"},
         {"slug": "wo-rl-bang-bang", "text": "wOéèärl !!"}],
        "length": 3, "has_tags": true}
    |}]
;;
