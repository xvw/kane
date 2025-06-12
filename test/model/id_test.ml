open Kane_model

let dump subject =
  subject |> Yocaml.Data.string |> Util_test.Dump.from (module Id)
;;

let%expect_test "id - 1" =
  "" |> dump;
  [%expect
    {|
    Error: --- Oh dear, an error has occurred ---
    Validation error: `test`

    Fail with message: { message = `Can't be blank`;given = ``;}
    ---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
    |}]
;;

let%expect_test "id - 2" =
  "foo bar baz" |> dump;
  [%expect
    {|
    Error: --- Oh dear, an error has occurred ---
    Validation error: `test`

    Fail with message: { message = `foo bar baz is not a valid slug`;
                         given = `foo bar baz`;}
    ---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
    |}]
;;

let%expect_test "id - 3" =
  "foo-bar-baz" |> dump;
  [%expect {| Ok: "foo-bar-baz" |}]
;;

let%expect_test "id - 4" =
  "@foobar-baz" |> dump;
  [%expect {| Ok: "foobar-baz" |}]
;;

let%expect_test "id - 5" =
  "$foobar-baz" |> dump;
  [%expect {| Ok: "foobar-baz" |}]
;;
