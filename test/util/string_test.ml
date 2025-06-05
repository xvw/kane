module KS = Kane_util.String

let%expect_test "concat_with using an empty list" =
  print_endline @@ KS.concat_with string_of_int ", " [];
  [%expect {| |}]
;;

let%expect_test "concat_with using a 1-list" =
  print_endline @@ KS.concat_with string_of_int ", " [ 1 ];
  [%expect {| 1 |}]
;;

let%expect_test "concat_with using a regular list" =
  print_endline @@ KS.concat_with string_of_int ", " [ 1; 2; 3; 4 ];
  [%expect {| 1, 2, 3, 4 |}]
;;
