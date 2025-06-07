open Kane_model

let dump subject =
  subject
  |> Yocaml.Data.string
  |> Email.validate
  |> Util_test.Dump.normalization Email.normalize
;;

let%expect_test "email - 1" =
  dump "xavier@muhokama.fun";
  [%expect
    {|
    Ok: {"address": "xavier@muhokama.fun", "local": "xavier", "domain":
         "muhokama.fun", "domain_fragments": ["muhokama", "fun"]}
    |}]
;;

let%expect_test "email - 2" =
  dump "xavier+nospam@xvw.lol";
  [%expect
    {|
    Ok: {"address": "xavier+nospam@xvw.lol", "local": "xavier+nospam", "domain":
         "xvw.lol", "domain_fragments": ["xvw", "lol"]}
    |}]
;;

let%expect_test "email - 3" =
  dump "xavier+nospam@@xvw.lol";
  [%expect
    {|
    Error: --- Oh dear, an error has occurred ---
    Validation error: `test`

    Fail with message: { message = `Invalid `xavier+nospam@@xvw.lol``;
                         given = `xavier+nospam@@xvw.lol`;}
    ---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
    |}]
;;
