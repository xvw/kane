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
