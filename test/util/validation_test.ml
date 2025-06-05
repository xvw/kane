open Kane_util

let pp spp ppf = function
  | Ok x -> Format.fprintf ppf "Ok: %a" spp x
  | Error error ->
    let e =
      Yocaml.(
        Eff.Provider_error
          (Required.Validation_error { entity = "test"; error }))
    in
    Format.fprintf
      ppf
      "Error: %a"
      (fun ppf x ->
         Yocaml.Diagnostic.exception_to_diagnostic
           ~in_exception_handler:false
           ppf
           x)
      e
;;

let dump spp x = x |> Format.asprintf "%a" (pp spp) |> print_endline

let%expect_test
    "required 1 - with an empty set, it should lead to an unknown field"
  =
  let open Yocaml.Data.Validation in
  let input = Yocaml.Data.(record []) in
  let result =
    record (fun fields -> Validation.required fields [] string) input
  in
  dump Format.pp_print_string result;
  [%expect
    {|
    Error: --- Oh dear, an error has occurred ---
    Validation error: `test`

    Fail with Invalid record: {errors = `Missing field = `unknown_field``;
                                given = ``;}]
    ---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
    |}]
;;

let%expect_test "required 2 - using the main field name" =
  let open Yocaml.Data.Validation in
  let input =
    Yocaml.Data.(record [ "main_title", string "hello"; "other_field", int 1 ])
  in
  let result =
    record
      (fun fields ->
         Validation.required fields [ "main_title"; "title" ] string)
      input
  in
  dump Format.pp_print_string result;
  [%expect {| Ok: hello |}]
;;

let%expect_test "required 2 - using the secondary field name" =
  let open Yocaml.Data.Validation in
  let input =
    Yocaml.Data.(record [ "title", string "hello"; "other_field", int 1 ])
  in
  let result =
    record
      (fun fields ->
         Validation.required fields [ "main_title"; "title" ] string)
      input
  in
  dump Format.pp_print_string result;
  [%expect {| Ok: hello |}]
;;

let%expect_test "required 3 - without field" =
  let open Yocaml.Data.Validation in
  let input = Yocaml.Data.(record [ "other_field", int 1 ]) in
  let result =
    record
      (fun fields ->
         Validation.required fields [ "main_title"; "title" ] string)
      input
  in
  dump Format.pp_print_string result;
  [%expect
    {|
    Error: --- Oh dear, an error has occurred ---
    Validation error: `test`

    Fail with Invalid record: {errors = `Missing field = `title``;
                                given = `other_field = `1``;}]
    ---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
    |}]
;;

let%expect_test "optional 1 - without fields" =
  let open Yocaml.Data.Validation in
  let input = Yocaml.Data.(record [ "other_field", int 1 ]) in
  let result =
    record
      (fun fields ->
         Validation.optional fields [ "main_title"; "title" ] string)
      input
  in
  dump Format.(pp_print_option pp_print_string) result;
  [%expect {| Ok: |}]
;;

let%expect_test "optional 2 - with main field" =
  let open Yocaml.Data.Validation in
  let input =
    Yocaml.Data.(record [ "main_title", string "foo"; "other_field", int 1 ])
  in
  let result =
    record
      (fun fields ->
         Validation.optional fields [ "main_title"; "title" ] string)
      input
  in
  dump Format.(pp_print_option pp_print_string) result;
  [%expect {| Ok: foo |}]
;;

let%expect_test "optional 3 - with secondary field" =
  let open Yocaml.Data.Validation in
  let input =
    Yocaml.Data.(record [ "title", string "foo"; "other_field", int 1 ])
  in
  let result =
    record
      (fun fields ->
         Validation.optional fields [ "main_title"; "title" ] string)
      input
  in
  dump Format.(pp_print_option pp_print_string) result;
  [%expect {| Ok: foo |}]
;;

let%expect_test "optional 3 - with empty fieldset" =
  let open Yocaml.Data.Validation in
  let input =
    Yocaml.Data.(record [ "title", string "foo"; "other_field", int 1 ])
  in
  let result =
    record (fun fields -> Validation.optional fields [] string) input
  in
  dump Format.(pp_print_option pp_print_string) result;
  [%expect {| Ok: |}]
;;
