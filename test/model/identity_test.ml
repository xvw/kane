open Kane_model

let dump subject = subject |> Util_test.Dump.from (module Identity)

let%expect_test "identity - 1" =
  "Xavier Van de Woestyne <xavier@xvw.lol>" |> Yocaml.Data.string |> dump;
  [%expect
    {|
    Ok: {"id": "xavier-van-de-woestyne", "display_name":
         "Xavier Van de Woestyne", "first_name": null, "last_name": null,
        "avatar": null, "website": null, "email":
         {"address": "xavier@xvw.lol", "local": "xavier", "domain": "xvw.lol",
         "domain_fragments": ["xvw", "lol"], "address_md5":
          "8ce48f56c9de1e079ceee7f064ee38f4"},
        "accounts":
         {"x": null, "bluesky": null, "mastodon": null, "github": null, "other":
          [], "has_x": false, "has_bluesky": false, "has_mastodon": false,
         "has_github": false, "has_other": false},
        "links": [], "emails":
         {"elements": [], "length": 0, "has_elements": false}, "attributes":
         {"elements": [], "length": 0, "has_elements": false}, "has_accounts":
         false, "has_first_name": false, "has_last_name": false, "has_avatar":
         false, "has_website": false, "has_email": true, "has_links": false,
        "has_emails": false, "has_attributes": false}
    |}]
;;

let%expect_test "identity - 2" =
  let open Yocaml.Data in
  record [] |> dump;
  [%expect
    {|
    Error: --- Oh dear, an error has occurred ---
    Validation error: `test`

    Fail with Invalid record: {errors = `Missing field = `user_name``;given = ``;
                                }]
    ---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
    |}]
;;

let%expect_test "identity - 3" =
  let open Yocaml.Data in
  record
    [ "display_name", string "xvw"
    ; "first_name", string "Xavier"
    ; "last_name", string "Vdw"
    ; "email", string "me@pgp.org"
    ]
  |> dump;
  [%expect
    {|
    Ok: {"id": "xvw", "display_name": "xvw", "first_name": "Xavier", "last_name":
         "Vdw", "avatar": null, "website": null, "email":
         {"address": "me@pgp.org", "local": "me", "domain": "pgp.org",
         "domain_fragments": ["pgp", "org"], "address_md5":
          "7007bdb28b0f9dbc7dbedde36e1b7447"},
        "accounts":
         {"x": null, "bluesky": null, "mastodon": null, "github": null, "other":
          [], "has_x": false, "has_bluesky": false, "has_mastodon": false,
         "has_github": false, "has_other": false},
        "links": [], "emails":
         {"elements": [], "length": 0, "has_elements": false}, "attributes":
         {"elements": [], "length": 0, "has_elements": false}, "has_accounts":
         false, "has_first_name": true, "has_last_name": true, "has_avatar":
         false, "has_website": false, "has_email": true, "has_links": false,
        "has_emails": false, "has_attributes": false}
    |}]
;;

let%expect_test "identity - 4" =
  let open Yocaml.Data in
  record
    [ "display_name", string "xvw"
    ; "first_name", string "Xavier"
    ; "last_name", string "Vdw"
    ; "email", string "me@pgp.org"
    ; "github", string "xvw"
    ]
  |> dump;
  [%expect
    {|
    Ok: {"id": "xvw", "display_name": "xvw", "first_name": "Xavier", "last_name":
         "Vdw", "avatar": null, "website": null, "email":
         {"address": "me@pgp.org", "local": "me", "domain": "pgp.org",
         "domain_fragments": ["pgp", "org"], "address_md5":
          "7007bdb28b0f9dbc7dbedde36e1b7447"},
        "accounts":
         {"x": null, "bluesky": null, "mastodon": null, "github": "xvw", "other":
          [], "has_x": false, "has_bluesky": false, "has_mastodon": false,
         "has_github": true, "has_other": false},
        "links": [], "emails":
         {"elements": [], "length": 0, "has_elements": false}, "attributes":
         {"elements": [], "length": 0, "has_elements": false}, "has_accounts":
         true, "has_first_name": true, "has_last_name": true, "has_avatar":
         false, "has_website": false, "has_email": true, "has_links": false,
        "has_emails": false, "has_attributes": false}
    |}]
;;
