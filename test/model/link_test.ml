open Kane_model

let make ?title url =
  let open Yocaml.Data in
  record [ "title", option string title; "url", string url ]
;;

let dump subject = subject |> Util_test.Dump.from (module Link)

let%expect_test "link - 1" =
  dump (make "https://xvw.lol");
  [%expect
    {|
    Ok: {"title": "xvw.lol", "url":
         {"target": "https://xvw.lol", "is_internal": false, "is_external":
          true, "kind": "external", "repr":
          {"full": "https://xvw.lol", "domain": "xvw.lol", "domain_with_path":
           "xvw.lol"},
         "uri":
          {"scheme": "https", "host": "xvw.lol", "port": null, "path": "",
          "query": [], "has_scheme": true, "has_host": true, "has_port": false,
          "has_query": false},
         "scheme": "https"}}
    |}]
;;

let%expect_test "link - 2" =
  dump (make "https://xvw.lol/foo/bar/baz");
  [%expect
    {|
    Ok: {"title": "xvw.lol/foo/bar/baz", "url":
         {"target": "https://xvw.lol/foo/bar/baz", "is_internal": false,
         "is_external": true, "kind": "external", "repr":
          {"full": "https://xvw.lol/foo/bar/baz", "domain": "xvw.lol",
          "domain_with_path": "xvw.lol/foo/bar/baz"},
         "uri":
          {"scheme": "https", "host": "xvw.lol", "port": null, "path":
           "/foo/bar/baz", "query": [], "has_scheme": true, "has_host": true,
          "has_port": false, "has_query": false},
         "scheme": "https"}}
    |}]
;;

let%expect_test "link - 3" =
  dump (make ~title:"Xvw's website" "https://xvw.lol/foo/bar/baz");
  [%expect
    {|
    Ok: {"title": "Xvw's website", "url":
         {"target": "https://xvw.lol/foo/bar/baz", "is_internal": false,
         "is_external": true, "kind": "external", "repr":
          {"full": "https://xvw.lol/foo/bar/baz", "domain": "xvw.lol",
          "domain_with_path": "xvw.lol/foo/bar/baz"},
         "uri":
          {"scheme": "https", "host": "xvw.lol", "port": null, "path":
           "/foo/bar/baz", "query": [], "has_scheme": true, "has_host": true,
          "has_port": false, "has_query": false},
         "scheme": "https"}}
    |}]
;;
