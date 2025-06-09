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

let%expect_test "remove_first_char_when - 1" =
  print_endline @@ KS.remove_first_char_when (fun _ -> true) ""
;;

let%expect_test "remove_first_char_when - 2" =
  print_endline @@ KS.remove_first_char_when (fun _ -> true) "f"
;;

let%expect_test "remove_first_char_when - 3" =
  print_endline @@ KS.remove_first_char_when (fun _ -> true) "foo";
  [%expect {| oo |}]
;;

let%expect_test "remove_first_char_when - 4" =
  print_endline @@ KS.remove_first_char_when (Char.equal '@') "@xvw";
  [%expect {| xvw |}]
;;
