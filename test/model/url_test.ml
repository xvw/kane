open Kane_model

let dump subject =
  subject
  |> Yocaml.Data.string
  |> Url.validate
  |> Util_test.Dump.normalization Url.normalize
;;

let%expect_test "url 1" =
  dump "/foo/bar/baz";
  [%expect
    {|
    Ok: {"target": "/foo/bar/baz", "is_internal": true, "is_external": false,
        "kind": "internal", "repr":
         {"full": "/foo/bar/baz", "domain": "/foo/bar/baz", "domain_with_path":
          "/foo/bar/baz"},
        "uri":
         {"scheme": null, "host": null, "port": null, "path": "/foo/bar/baz",
         "query": [], "has_scheme": false, "has_host": false, "has_port": false,
         "has_query": false},
        "scheme": null}
    |}]
;;

let%expect_test "url 2" =
  dump "foo/bar/baz";
  [%expect
    {|
    Ok: {"target": "foo/bar/baz", "is_internal": true, "is_external": false,
        "kind": "internal", "repr":
         {"full": "foo/bar/baz", "domain": "./foo/bar/baz", "domain_with_path":
          "./foo/bar/baz"},
        "uri":
         {"scheme": null, "host": null, "port": null, "path": "foo/bar/baz",
         "query": [], "has_scheme": false, "has_host": false, "has_port": false,
         "has_query": false},
        "scheme": null}
    |}]
;;

let%expect_test "url 3" =
  dump "foo/bar/baz?x=102&22=33&bar=12";
  [%expect
    {|
    Ok: {"target": "foo/bar/baz?x=102&22=33&bar=12", "is_internal": true,
        "is_external": false, "kind": "internal", "repr":
         {"full": "foo/bar/baz?x=102&22=33&bar=12", "domain": "./foo/bar/baz",
         "domain_with_path": "./foo/bar/baz"},
        "uri":
         {"scheme": null, "host": null, "port": null, "path": "foo/bar/baz",
         "query":
          [{"key": "22", "value": ["33"]}, {"key": "bar", "value": ["12"]},
          {"key": "x", "value": ["102"]}],
         "has_scheme": false, "has_host": false, "has_port": false, "has_query":
          true},
        "scheme": null}
    |}]
;;

let%expect_test "url 4" =
  dump "https://xvw.lol/foo/bar/baz?x=102&22=33&bar=12";
  [%expect
    {|
    Ok: {"target": "https://xvw.lol/foo/bar/baz?x=102&22=33&bar=12",
        "is_internal": false, "is_external": true, "kind": "external", "repr":
         {"full": "https://xvw.lol/foo/bar/baz?x=102&22=33&bar=12", "domain":
          "xvw.lol", "domain_with_path": "xvw.lol/foo/bar/baz"},
        "uri":
         {"scheme": "https", "host": "xvw.lol", "port": null, "path":
          "/foo/bar/baz", "query":
          [{"key": "22", "value": ["33"]}, {"key": "bar", "value": ["12"]},
          {"key": "x", "value": ["102"]}],
         "has_scheme": true, "has_host": true, "has_port": false, "has_query":
          true},
        "scheme": "https"}
    |}]
;;

let%expect_test "url 5" =
  dump "https://xvw.lol:8888/foo/bar/baz?x=102&22=33&bar=12";
  [%expect
    {|
    Ok: {"target": "https://xvw.lol:8888/foo/bar/baz?x=102&22=33&bar=12",
        "is_internal": false, "is_external": true, "kind": "external", "repr":
         {"full": "https://xvw.lol:8888/foo/bar/baz?x=102&22=33&bar=12",
         "domain": "xvw.lol", "domain_with_path": "xvw.lol/foo/bar/baz"},
        "uri":
         {"scheme": "https", "host": "xvw.lol", "port": 8888, "path":
          "/foo/bar/baz", "query":
          [{"key": "22", "value": ["33"]}, {"key": "bar", "value": ["12"]},
          {"key": "x", "value": ["102"]}],
         "has_scheme": true, "has_host": true, "has_port": true, "has_query":
          true},
        "scheme": "https"}
    |}]
;;
