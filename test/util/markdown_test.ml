open Kane_util

let dump links =
  links
  |> Format.asprintf
       "[@[%a@]]"
       (Format.pp_print_list
          ~pp_sep:(fun ppf () -> Format.fprintf ppf ";@ ")
          Format.pp_print_text)
  |> print_endline
;;

let test_resolver map doc =
  doc
  |> Cmarkit.Doc.of_string ~heading_auto_ids:true ~strict:false
  |> Markdown.resolve_links (fun id -> Stdlib.List.assoc_opt id map)
  |> Cmarkit_html.of_doc ~safe:false
  |> print_endline
;;

let%expect_test "collect_links - 1" =
  {||} |> Markdown.collect_links |> dump;
  [%expect {| [] |}]
;;

let%expect_test "collect_links - 2" =
  {| Hello *world* ! Look at <kane:foo-bar-baz>|}
  |> Markdown.collect_links
  |> dump;
  [%expect {| [foo-bar-baz] |}]
;;

let%expect_test "collect_links - 2" =
  {| Hello *world* ! Look at <kane:foo-bar-baz> or [here](<kane:baz> "a title"), and here: <id:foo-baz>, or not here <https://google.fr>. [test](https://xvw.lol "foo")|}
  |> Markdown.collect_links
  |> dump;
  [%expect {| [foo-baz; baz; foo-bar-baz] |}]
;;

let%expect_test "resolve_links - 1" =
  test_resolver [] "Hello World";
  [%expect {| <p>Hello World</p> |}]
;;

let%expect_test "resolve_links - 2" =
  test_resolver [] "Hello World <kane:foo>";
  [%expect {| <p>Hello World <a href="kane:foo">kane:foo</a></p> |}]
;;

let%expect_test "resolve_links - 3" =
  test_resolver [ "foo", ("/foo", "page Foo", None) ] "Hello World <kane:foo>";
  [%expect {| <p>Hello World <a href="/foo">page Foo</a></p> |}]
;;

let%expect_test "resolve_links - 4" =
  test_resolver
    [ "foo", ("/foo", "page Foo", Some "Lien vers la page foo") ]
    "Hello World <kane:foo>";
  [%expect
    {| <p>Hello World <a href="/foo" title="Lien vers la page foo">page Foo</a></p> |}]
;;

let%expect_test "resolve_links - 5" =
  test_resolver
    [ "foo", ("/foo", "page Foo", Some "Lien vers la page foo") ]
    "Hello World [](<kane:foo>)";
  [%expect
    {| <p>Hello World <a href="/foo" title="Lien vers la page foo">page Foo</a></p> |}]
;;

let%expect_test "resolve_links - 6" =
  test_resolver
    [ "foo", ("/foo", "page Foo", Some "Lien vers la page foo") ]
    "Hello World [](<kane:foo> \"My link\")";
  [%expect {| <p>Hello World <a href="/foo" title="My link">page Foo</a></p> |}]
;;

let%expect_test "resolve_links - 7" =
  test_resolver
    [ "foo", ("/foo", "page Foo", Some "Lien vers la page foo") ]
    "Hello World [La page foooooo](<kane:foo> \"My link\")";
  [%expect {| <p>Hello World <a href="/foo" title="My link">La page foooooo</a></p> |}]
;;
