let folder =
  Kane_util.List.fold_lefti
    (fun i buf x -> Format.asprintf "%s;%d-%s" buf i x)
    ""
;;

let%expect_test "fold_lefti - 1" =
  print_endline @@ folder [ "foo"; "bar"; "baz" ];
  [%expect {| ;0-foo;1-bar;2-baz |}]
;;

let%expect_test "fold_lefti - 2" =
  print_endline @@ folder [ "foo" ];
  [%expect {| ;0-foo |}]
;;

let%expect_test "fold_lefti - 3" =
  print_endline @@ folder [];
  [%expect {| |}]
;;
