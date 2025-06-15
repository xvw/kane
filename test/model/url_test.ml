open Kane_model

let dump subject =
  subject |> Yocaml.Data.string |> Util_test.Dump.from (module Url)
;;

let dump_url f s =
  s
  |> Yocaml.Data.string
  |> Url.validate
  |> Result.map f
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
         "query": {"elements": [], "length": 0, "has_elements": false},
         "has_scheme": false, "has_host": false, "has_port": false, "has_query":
          false},
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
         "query": {"elements": [], "length": 0, "has_elements": false},
         "has_scheme": false, "has_host": false, "has_port": false, "has_query":
          false},
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
          {"elements":
           [{"key": "22", "value": ["33"]}, {"key": "bar", "value": ["12"]},
           {"key": "x", "value": ["102"]}],
          "length": 3, "has_elements": true},
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
          {"elements":
           [{"key": "22", "value": ["33"]}, {"key": "bar", "value": ["12"]},
           {"key": "x", "value": ["102"]}],
          "length": 3, "has_elements": true},
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
          {"elements":
           [{"key": "22", "value": ["33"]}, {"key": "bar", "value": ["12"]},
           {"key": "x", "value": ["102"]}],
          "length": 3, "has_elements": true},
         "has_scheme": true, "has_host": true, "has_port": true, "has_query":
          true},
        "scheme": "https"}
    |}]
;;

let%expect_test "url resolve - 1" =
  let path = Yocaml.Path.abs [] in
  "https://xvw.lol" |> dump_url (fun url -> Url.resolve url path);
  [%expect
    {|
    Ok: {"target": "https://xvw.lol/", "is_internal": false, "is_external":
         true, "kind": "external", "repr":
         {"full": "https://xvw.lol/", "domain": "xvw.lol", "domain_with_path":
          "xvw.lol"},
        "uri":
         {"scheme": "https", "host": "xvw.lol", "port": null, "path": "/",
         "query": {"elements": [], "length": 0, "has_elements": false},
         "has_scheme": true, "has_host": true, "has_port": false, "has_query":
          false},
        "scheme": "https"}
    |}]
;;

let%expect_test "url resolve - 2" =
  let path = Yocaml.Path.abs [ "foo" ] in
  "https://xvw.lol" |> dump_url (fun url -> Url.resolve url path);
  [%expect
    {|
    Ok: {"target": "https://xvw.lol/foo", "is_internal": false, "is_external":
         true, "kind": "external", "repr":
         {"full": "https://xvw.lol/foo", "domain": "xvw.lol", "domain_with_path":
          "xvw.lol/foo"},
        "uri":
         {"scheme": "https", "host": "xvw.lol", "port": null, "path": "/foo",
         "query": {"elements": [], "length": 0, "has_elements": false},
         "has_scheme": true, "has_host": true, "has_port": false, "has_query":
          false},
        "scheme": "https"}
    |}]
;;

let%expect_test "url resolve - 3" =
  let path = Yocaml.Path.abs [ "foo"; "bar" ] in
  "https://xvw.lol" |> dump_url (fun url -> Url.resolve url path);
  [%expect
    {|
    Ok: {"target": "https://xvw.lol/foo/bar", "is_internal": false,
        "is_external": true, "kind": "external", "repr":
         {"full": "https://xvw.lol/foo/bar", "domain": "xvw.lol",
         "domain_with_path": "xvw.lol/foo/bar"},
        "uri":
         {"scheme": "https", "host": "xvw.lol", "port": null, "path":
          "/foo/bar", "query":
          {"elements": [], "length": 0, "has_elements": false}, "has_scheme":
          true, "has_host": true, "has_port": false, "has_query": false},
        "scheme": "https"}
    |}]
;;

let%expect_test "url resolve - 4" =
  let path = Yocaml.Path.abs [ "foo"; "bar"; "baz" ] in
  "https://xvw.lol/foo/bar" |> dump_url (fun url -> Url.resolve url path);
  [%expect
    {|
    Ok: {"target": "https://xvw.lol/foo/bar/baz", "is_internal": false,
        "is_external": true, "kind": "external", "repr":
         {"full": "https://xvw.lol/foo/bar/baz", "domain": "xvw.lol",
         "domain_with_path": "xvw.lol/foo/bar/baz"},
        "uri":
         {"scheme": "https", "host": "xvw.lol", "port": null, "path":
          "/foo/bar/baz", "query":
          {"elements": [], "length": 0, "has_elements": false}, "has_scheme":
          true, "has_host": true, "has_port": false, "has_query": false},
        "scheme": "https"}
    |}]
;;

let%expect_test "url resolve - 5" =
  let path = Yocaml.Path.rel [ "foo"; "bar"; "baz" ] in
  "https://xvw.lol/foo/bar" |> dump_url (fun url -> Url.resolve url path);
  [%expect
    {|
    Ok: {"target": "https://xvw.lol/foo/bar/foo/bar/baz", "is_internal": false,
        "is_external": true, "kind": "external", "repr":
         {"full": "https://xvw.lol/foo/bar/foo/bar/baz", "domain": "xvw.lol",
         "domain_with_path": "xvw.lol/foo/bar/foo/bar/baz"},
        "uri":
         {"scheme": "https", "host": "xvw.lol", "port": null, "path":
          "/foo/bar/foo/bar/baz", "query":
          {"elements": [], "length": 0, "has_elements": false}, "has_scheme":
          true, "has_host": true, "has_port": false, "has_query": false},
        "scheme": "https"}
    |}]
;;

let%expect_test "url resolve - 6" =
  let path = Yocaml.Path.abs [ "a"; "b"; "c" ] in
  "https://xvw.lol/foo/bar" |> dump_url (fun url -> Url.resolve url path);
  [%expect
    {|
    Ok: {"target": "https://xvw.lol/a/b/c", "is_internal": false, "is_external":
         true, "kind": "external", "repr":
         {"full": "https://xvw.lol/a/b/c", "domain": "xvw.lol",
         "domain_with_path": "xvw.lol/a/b/c"},
        "uri":
         {"scheme": "https", "host": "xvw.lol", "port": null, "path": "/a/b/c",
         "query": {"elements": [], "length": 0, "has_elements": false},
         "has_scheme": true, "has_host": true, "has_port": false, "has_query":
          false},
        "scheme": "https"}
    |}]
;;

let%expect_test "url resolve - 7" =
  let path = Yocaml.Path.abs [ "a"; "b"; "c" ] in
  "https://xvw.lol/foo/bar?a=foo&k=1,2,4"
  |> dump_url (fun url -> Url.resolve url path);
  [%expect
    {|
    Ok: {"target": "https://xvw.lol/a/b/c?a=foo&k=1,2,4", "is_internal": false,
        "is_external": true, "kind": "external", "repr":
         {"full": "https://xvw.lol/a/b/c?a=foo&k=1,2,4", "domain": "xvw.lol",
         "domain_with_path": "xvw.lol/a/b/c"},
        "uri":
         {"scheme": "https", "host": "xvw.lol", "port": null, "path": "/a/b/c",
         "query":
          {"elements":
           [{"key": "a", "value": ["foo"]},
           {"key": "k", "value": ["1", "2", "4"]}],
          "length": 2, "has_elements": true},
         "has_scheme": true, "has_host": true, "has_port": false, "has_query":
          true},
        "scheme": "https"}
    |}]
;;
