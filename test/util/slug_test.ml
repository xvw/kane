open Kane_util

let dump = print_endline

let%expect_test "from_path - 1" =
  Yocaml.Path.(abs []) |> Slug.from_path |> dump;
  [%expect {| root |}]
;;

let%expect_test "from_path - 2" =
  Yocaml.Path.(rel []) |> Slug.from_path |> dump;
  [%expect {| rel |}]
;;

let%expect_test "from_path - 3" =
  Yocaml.Path.(rel [ "foo"; "bar"; "baz.png" ]) |> Slug.from_path |> dump;
  [%expect {| foo-bar-baz-png |}]
;;
