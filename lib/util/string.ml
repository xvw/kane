let concat_with f sep list =
  let res, _ =
    List.fold_left
      (fun (acc, i) x ->
         let sep = if Int.equal i 0 then "" else sep in
         acc ^ sep ^ f x, succ i)
      ("", 0)
      list
  in
  res
;;

let%expect_test "concat_with using an empty list" =
  print_endline @@ concat_with string_of_int ", " [];
  [%expect {| |}]
;;

let%expect_test "concat_with using a 1-list" =
  print_endline @@ concat_with string_of_int ", " [ 1 ];
  [%expect {| 1 |}]
;;

let%expect_test "concat_with using a regular list" =
  print_endline @@ concat_with string_of_int ", " [ 1; 2; 3; 4 ];
  [%expect {| 1, 2, 3, 4 |}]
;;
