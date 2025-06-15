open Kane_util

let dump data =
  let data = data |> to_sexp in
  data |> Yocaml.Sexp.to_string |> print_endline;
  data |> Yocaml.Sexp.Canonical.to_string |> print_endline
;;

open Yocaml.Data

let%expect_test "to_sexp - 1" =
  null |> dump;
  [%expect
    {|
    ()
    ()
    |}]
;;

let%expect_test "to_sexp - 2" =
  int 64 |> dump;
  [%expect
    {|
    64
    2:64
    |}]
;;

let%expect_test "to_sexp - 3" =
  list_of string [ "foo"; "bar"; "baz" ] |> dump;
  [%expect
    {|
    (foo bar baz)
    (3:foo3:bar3:baz)
    |}]
;;

let%expect_test "to_sexp - 4" =
  record
    [ "foo", int 12; "bar", bool true; "baz", either float string (Left 42.12) ]
  |> dump;
  [%expect
    {|
    ((foo 12) (bar true) (baz ((constr left) (value 42.12))))
    ((3:foo2:12)(3:bar4:true)(3:baz((6:constr4:left)(5:value5:42.12))))
    |}]
;;

let%expect_test "to_sexp - 5" =
  record
    [ "foo", int 12
    ; "bar", bool true
    ; "baz", either float string (Left 42.12)
    ; "test", option int (Some 10)
    ]
  |> dump;
  [%expect
    {|
    ((foo 12) (bar true) (baz ((constr left) (value 42.12))) (test 10))
    ((3:foo2:12)(3:bar4:true)(3:baz((6:constr4:left)(5:value5:42.12)))(4:test2:10))
    |}]
;;

let%expect_test "to_sexp - 6" =
  record
    [ "foo", int 12
    ; "bar", bool true
    ; "baz", either float string (Right "12")
    ; "test", option int None
    ]
  |> dump;
  [%expect
    {|
    ((foo 12) (bar true) (baz ((constr right) (value 12))))
    ((3:foo2:12)(3:bar4:true)(3:baz((6:constr5:right)(5:value2:12))))
    |}]
;;
