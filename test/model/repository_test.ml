open Kane_model

let dump subject =
  subject
  |> Yocaml.Data.string
  |> Repository.validate
  |> Util_test.Dump.normalization Repository.normalize
;;

let%expect_test "repo - 1" =
  "" |> dump;
  [%expect
    {|
    Error: --- Oh dear, an error has occurred ---
    Validation error: `test`

    Fail with message: { message = `Unknown repository uri`;given = ``;}
    ---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
    |}]
;;

let%expect_test "repo - 2" =
  "github/xvw/kane" |> dump;
  [%expect
    {|
    Ok: {"kind": "github", "is_organization": false, "components":
         ["xvw", "kane"], "homepage":
         {"target": "https://github.com/xvw/kane", "is_internal": false,
         "is_external": true, "kind": "external", "repr":
          {"full": "https://github.com/xvw/kane", "domain": "github.com",
          "domain_with_path": "github.com/xvw/kane"},
         "uri":
          {"scheme": "https", "host": "github.com", "port": null, "path":
           "/xvw/kane", "query": [], "has_scheme": true, "has_host": true,
          "has_port": false, "has_query": false},
         "scheme": "https"},
        "bug-tracker":
         {"target": "https://github.com/xvw/kane/issues", "is_internal": false,
         "is_external": true, "kind": "external", "repr":
          {"full": "https://github.com/xvw/kane/issues", "domain": "github.com",
          "domain_with_path": "github.com/xvw/kane/issues"},
         "uri":
          {"scheme": "https", "host": "github.com", "port": null, "path":
           "/xvw/kane/issues", "query": [], "has_scheme": true, "has_host":
           true, "has_port": false, "has_query": false},
         "scheme": "https"},
        "clone":
         {"https": "https://github.com/xvw/kane.git", "ssh": "<to-be-done>"}}
    |}]
;;

let%expect_test "repo - 3" =
  "github.com/xvw/kane" |> dump;
  [%expect
    {|
    Ok: {"kind": "github", "is_organization": false, "components":
         ["xvw", "kane"], "homepage":
         {"target": "https://github.com/xvw/kane", "is_internal": false,
         "is_external": true, "kind": "external", "repr":
          {"full": "https://github.com/xvw/kane", "domain": "github.com",
          "domain_with_path": "github.com/xvw/kane"},
         "uri":
          {"scheme": "https", "host": "github.com", "port": null, "path":
           "/xvw/kane", "query": [], "has_scheme": true, "has_host": true,
          "has_port": false, "has_query": false},
         "scheme": "https"},
        "bug-tracker":
         {"target": "https://github.com/xvw/kane/issues", "is_internal": false,
         "is_external": true, "kind": "external", "repr":
          {"full": "https://github.com/xvw/kane/issues", "domain": "github.com",
          "domain_with_path": "github.com/xvw/kane/issues"},
         "uri":
          {"scheme": "https", "host": "github.com", "port": null, "path":
           "/xvw/kane/issues", "query": [], "has_scheme": true, "has_host":
           true, "has_port": false, "has_query": false},
         "scheme": "https"},
        "clone":
         {"https": "https://github.com/xvw/kane.git", "ssh": "<to-be-done>"}}
    |}]
;;

let%expect_test "repo - 4" =
  "tangled/@xvw.lol/kane" |> dump;
  [%expect
    {|
    Ok: {"kind": "tangled", "is_organization": false, "components":
         ["xvw.lol", "kane"], "homepage":
         {"target": "https://tangled.sh/@xvw.lol/kane", "is_internal": false,
         "is_external": true, "kind": "external", "repr":
          {"full": "https://tangled.sh/@xvw.lol/kane", "domain": "tangled.sh",
          "domain_with_path": "tangled.sh/@xvw.lol/kane"},
         "uri":
          {"scheme": "https", "host": "tangled.sh", "port": null, "path":
           "/@xvw.lol/kane", "query": [], "has_scheme": true, "has_host": true,
          "has_port": false, "has_query": false},
         "scheme": "https"},
        "bug-tracker":
         {"target": "https://tangled.sh/@xvw.lol/kane/issues", "is_internal":
          false, "is_external": true, "kind": "external", "repr":
          {"full": "https://tangled.sh/@xvw.lol/kane/issues", "domain":
           "tangled.sh", "domain_with_path": "tangled.sh/@xvw.lol/kane/issues"},
         "uri":
          {"scheme": "https", "host": "tangled.sh", "port": null, "path":
           "/@xvw.lol/kane/issues", "query": [], "has_scheme": true, "has_host":
           true, "has_port": false, "has_query": false},
         "scheme": "https"},
        "clone":
         {"https": "https://tangled.sh/@xvw.lol/kane", "ssh": "<to-be-done>"}}
    |}]
;;

let%expect_test "repo - 5" =
  "https://gitlab.com/funkywork/yocaml" |> dump;
  [%expect
    {|
    Ok: {"kind": "gitlab", "is_organization": false, "components":
         ["funkywork", "yocaml"], "homepage":
         {"target": "https://gitlab.com/funkywork/yocaml", "is_internal": false,
         "is_external": true, "kind": "external", "repr":
          {"full": "https://gitlab.com/funkywork/yocaml", "domain":
           "gitlab.com", "domain_with_path": "gitlab.com/funkywork/yocaml"},
         "uri":
          {"scheme": "https", "host": "gitlab.com", "port": null, "path":
           "/funkywork/yocaml", "query": [], "has_scheme": true, "has_host":
           true, "has_port": false, "has_query": false},
         "scheme": "https"},
        "bug-tracker":
         {"target": "https://gitlab.com/funkywork/yocaml/-/issues",
         "is_internal": false, "is_external": true, "kind": "external", "repr":
          {"full": "https://gitlab.com/funkywork/yocaml/-/issues", "domain":
           "gitlab.com", "domain_with_path":
           "gitlab.com/funkywork/yocaml/-/issues"},
         "uri":
          {"scheme": "https", "host": "gitlab.com", "port": null, "path":
           "/funkywork/yocaml/-/issues", "query": [], "has_scheme": true,
          "has_host": true, "has_port": false, "has_query": false},
         "scheme": "https"},
        "clone":
         {"https": "https://gitlab.com/funkywork/yocaml.git", "ssh":
          "<to-be-done>"}}
    |}]
;;
