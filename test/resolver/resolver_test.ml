open Kane_resolver
module Path = Yocaml.Path

let dump p = p |> Path.to_string |> print_endline
let resolver = new t ()

let%expect_test "target#resolve_page - 1" =
  let source = Path.(resolver#source#pages / "foo.md") in
  let target = resolver#target#resolve_page source in
  target |> dump;
  [%expect {| ./_www/pages/foo.html |}]
;;

let%expect_test "url#resolve_page - 1" =
  let source = Path.(resolver#source#pages / "foo.md") in
  let target = resolver#url#resolve_page source in
  target |> dump;
  [%expect {| /pages/foo.html |}]
;;

let%expect_test "url#resolve_page - 2" =
  let source = Path.(resolver#source#pages / "foo.md") in
  let target =
    resolver#url#resolve_page (resolver#target#resolve_page source)
  in
  target |> dump;
  [%expect {| /pages/foo.html |}]
;;
