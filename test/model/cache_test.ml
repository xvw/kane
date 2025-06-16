open Kane_model

let dump cache =
  let backlinks = Cache.backlinks cache in
  let references = Cache.references cache in
  let collisions = Cache.collisions cache in
  let missing_references = Cache.missing_references cache in
  let data =
    let open Yocaml.Data in
    record
      [ ( "references"
        , Id.Map.normalize
            (triple Kane_util.Path.normalize string (option string))
            references )
      ; "backlinks", Id.Map.normalize Id.Set.normalize backlinks
      ; ( "collisions"
        , option (Id.Map.normalize Kane_util.Path.Set.normalize) collisions )
      ; "missing_references", option Id.Set.normalize missing_references
      ]
  in
  data |> Format.asprintf "%a" Yocaml.Data.pp |> print_endline
;;

let%expect_test "from an empty cache" =
  let cache = Cache.empty in
  dump cache;
  [%expect
    {|
    {"references": {"elements": [], "length": 0, "has_elements": false},
    "backlinks": {"elements": [], "length": 0, "has_elements": false},
    "collisions": null, "missing_references": null}
    |}]
;;

let%expect_test "from a singleton cache" =
  let cache =
    Cache.empty
    |> Cache.visit
         ~id:(Id.from_slug "@xvw")
         ~path:(Yocaml.Path.rel [ "users"; "xvw" ])
         ~title:"Xavier's user page"
  in
  dump cache;
  [%expect
    {|
    {"references":
     {"elements":
      [{"key": "xvw", "value":
        {"fst": "./users/xvw", "snd": {"fst": "Xavier's user page", "snd": null}}}],
     "length": 1, "has_elements": true},
    "backlinks": {"elements": [], "length": 0, "has_elements": false},
    "collisions": null, "missing_references": null}
    |}]
;;

let%expect_test "from a more complicated cache" =
  let cache =
    Cache.empty
    |> Cache.visit
         ~id:(Id.from_slug "@xvw")
         ~path:(Yocaml.Path.rel [ "users"; "xvw" ])
         ~title:"Xavier's user page"
    |> Cache.visit
         ~id:(Id.from_slug "@grm")
         ~path:(Yocaml.Path.rel [ "users"; "grm" ])
         ~title:"Grim's user page"
    |> Cache.visit
         ~id:(Id.from_slug "@xhtmlboi")
         ~path:(Yocaml.Path.rel [ "users"; "xhtmlboi" ])
         ~title:"XHTMLBoy's user page"
    |> Cache.visit
         ~id:(Id.from_slug "@msp")
         ~path:(Yocaml.Path.rel [ "users"; "msp" ])
         ~title:"Msp's user page"
  in
  dump cache;
  [%expect
    {|
    {"references":
     {"elements":
      [{"key": "grm", "value":
        {"fst": "./users/grm", "snd": {"fst": "Grim's user page", "snd": null}}},
      {"key": "msp", "value":
       {"fst": "./users/msp", "snd": {"fst": "Msp's user page", "snd": null}}},
      {"key": "xhtmlboi", "value":
       {"fst": "./users/xhtmlboi", "snd":
        {"fst": "XHTMLBoy's user page", "snd": null}}},
      {"key": "xvw", "value":
       {"fst": "./users/xvw", "snd": {"fst": "Xavier's user page", "snd": null}}}],
     "length": 4, "has_elements": true},
    "backlinks": {"elements": [], "length": 0, "has_elements": false},
    "collisions": null, "missing_references": null}
    |}]
;;

let ids xs = List.map Id.from_string xs |> Id.Set.of_list

let%expect_test "from a more complicated cache and backlinks" =
  let cache =
    Cache.empty
    |> Cache.visit
         ~id:(Id.from_slug "@xvw")
         ~path:(Yocaml.Path.rel [ "users"; "xvw" ])
         ~title:"Xavier's user page"
         ~links:(ids [ "@grm"; "msp" ])
    |> Cache.visit
         ~id:(Id.from_slug "@grm")
         ~path:(Yocaml.Path.rel [ "users"; "grm" ])
         ~title:"Grim's user page"
         ~links:(ids [ "@xhtmlboi"; "xvw" ])
    |> Cache.visit
         ~id:(Id.from_slug "@xhtmlboi")
         ~path:(Yocaml.Path.rel [ "users"; "xhtmlboi" ])
         ~title:"XHTMLBoy's user page"
         ~links:(ids [ "@grm"; "msp"; "msp" ])
    |> Cache.visit
         ~id:(Id.from_slug "@msp")
         ~path:(Yocaml.Path.rel [ "users"; "msp" ])
         ~title:"Msp's user page"
         ~links:
           (ids
              [ "@grm"
              ; "msp" (* ensure that MSP is removed. *)
              ; "xvw"
              ; "xhtmlboi"
              ])
  in
  dump cache;
  [%expect
    {|
    {"references":
     {"elements":
      [{"key": "grm", "value":
        {"fst": "./users/grm", "snd": {"fst": "Grim's user page", "snd": null}}},
      {"key": "msp", "value":
       {"fst": "./users/msp", "snd": {"fst": "Msp's user page", "snd": null}}},
      {"key": "xhtmlboi", "value":
       {"fst": "./users/xhtmlboi", "snd":
        {"fst": "XHTMLBoy's user page", "snd": null}}},
      {"key": "xvw", "value":
       {"fst": "./users/xvw", "snd": {"fst": "Xavier's user page", "snd": null}}}],
     "length": 4, "has_elements": true},
    "backlinks":
     {"elements":
      [{"key": "grm", "value":
        {"elements": ["msp", "xhtmlboi", "xvw"], "length": 3, "has_elements":
         true}},
      {"key": "msp", "value":
       {"elements": ["xhtmlboi", "xvw"], "length": 2, "has_elements": true}},
      {"key": "xhtmlboi", "value":
       {"elements": ["grm", "msp"], "length": 2, "has_elements": true}},
      {"key": "xvw", "value":
       {"elements": ["grm", "msp"], "length": 2, "has_elements": true}}],
     "length": 4, "has_elements": true},
    "collisions": null, "missing_references": null}
    |}]
;;

let%expect_test "with missing references" =
  let cache =
    Cache.empty
    |> Cache.visit
         ~id:(Id.from_slug "@xvw")
         ~path:(Yocaml.Path.rel [ "users"; "xvw" ])
         ~title:"Xavier's user page"
         ~links:(ids [ "@grm"; "msp"; "fofooo" ])
    |> Cache.visit
         ~id:(Id.from_slug "@grm")
         ~path:(Yocaml.Path.rel [ "users"; "grm" ])
         ~title:"Grim's user page"
         ~links:(ids [ "@xhtmlboi"; "xvw"; "fofooo" ])
    |> Cache.visit
         ~id:(Id.from_slug "@xhtmlboi")
         ~path:(Yocaml.Path.rel [ "users"; "xhtmlboi" ])
         ~title:"XHTMLBoy's user page"
         ~links:(ids [ "@grm"; "msp"; "msp" ])
    |> Cache.visit
         ~id:(Id.from_slug "@msp")
         ~path:(Yocaml.Path.rel [ "users"; "msp" ])
         ~title:"Msp's user page"
         ~links:(ids [ "@grm"; "msp"; "xvw"; "xhtmlboi"; "bar" ])
  in
  dump cache;
  [%expect
    {|
    {"references":
     {"elements":
      [{"key": "grm", "value":
        {"fst": "./users/grm", "snd": {"fst": "Grim's user page", "snd": null}}},
      {"key": "msp", "value":
       {"fst": "./users/msp", "snd": {"fst": "Msp's user page", "snd": null}}},
      {"key": "xhtmlboi", "value":
       {"fst": "./users/xhtmlboi", "snd":
        {"fst": "XHTMLBoy's user page", "snd": null}}},
      {"key": "xvw", "value":
       {"fst": "./users/xvw", "snd": {"fst": "Xavier's user page", "snd": null}}}],
     "length": 4, "has_elements": true},
    "backlinks":
     {"elements":
      [{"key": "bar", "value":
        {"elements": ["msp"], "length": 1, "has_elements": true}},
      {"key": "fofooo", "value":
       {"elements": ["grm", "xvw"], "length": 2, "has_elements": true}},
      {"key": "grm", "value":
       {"elements": ["msp", "xhtmlboi", "xvw"], "length": 3, "has_elements":
        true}},
      {"key": "msp", "value":
       {"elements": ["xhtmlboi", "xvw"], "length": 2, "has_elements": true}},
      {"key": "xhtmlboi", "value":
       {"elements": ["grm", "msp"], "length": 2, "has_elements": true}},
      {"key": "xvw", "value":
       {"elements": ["grm", "msp"], "length": 2, "has_elements": true}}],
     "length": 6, "has_elements": true},
    "collisions": null, "missing_references": null}
    |}]
;;

let%expect_test "with fair collision" =
  let cache =
    Cache.empty
    |> Cache.visit
         ~id:(Id.from_slug "@xvw")
         ~path:(Yocaml.Path.rel [ "users"; "xvw" ])
         ~title:"Xavier's user page"
         ~links:(ids [ "@grm"; "msp" ])
    |> Cache.visit
         ~id:(Id.from_slug "@grm")
         ~path:(Yocaml.Path.rel [ "users"; "grm" ])
         ~title:"Grim's user page"
         ~links:(ids [ "@xhtmlboi"; "xvw" ])
    |> Cache.visit
         ~id:(Id.from_slug "@xhtmlboi")
         ~path:(Yocaml.Path.rel [ "users"; "xhtmlboi" ])
         ~title:"XHTMLBoy's user page"
         ~links:(ids [ "@grm"; "msp"; "msp" ])
    |> Cache.visit
         ~id:(Id.from_slug "@msp")
         ~path:(Yocaml.Path.rel [ "users"; "msp" ])
         ~title:"Msp's user page"
         ~links:(ids [ "@grm"; "msp"; "xhtmlboi" ])
    |> Cache.visit
         ~id:(Id.from_slug "msp")
         ~path:(Yocaml.Path.rel [ "users"; "msp" ])
         ~title:"Msp's user page"
         ~links:(ids [ "msp"; "xvw" ])
  in
  dump cache;
  [%expect
    {|
    {"references":
     {"elements":
      [{"key": "grm", "value":
        {"fst": "./users/grm", "snd": {"fst": "Grim's user page", "snd": null}}},
      {"key": "msp", "value":
       {"fst": "./users/msp", "snd": {"fst": "Msp's user page", "snd": null}}},
      {"key": "xhtmlboi", "value":
       {"fst": "./users/xhtmlboi", "snd":
        {"fst": "XHTMLBoy's user page", "snd": null}}},
      {"key": "xvw", "value":
       {"fst": "./users/xvw", "snd": {"fst": "Xavier's user page", "snd": null}}}],
     "length": 4, "has_elements": true},
    "backlinks":
     {"elements":
      [{"key": "grm", "value":
        {"elements": ["msp", "xhtmlboi", "xvw"], "length": 3, "has_elements":
         true}},
      {"key": "msp", "value":
       {"elements": ["xhtmlboi", "xvw"], "length": 2, "has_elements": true}},
      {"key": "xhtmlboi", "value":
       {"elements": ["grm", "msp"], "length": 2, "has_elements": true}},
      {"key": "xvw", "value":
       {"elements": ["grm", "msp"], "length": 2, "has_elements": true}}],
     "length": 4, "has_elements": true},
    "collisions": null, "missing_references": null}
    |}]
;;

let%expect_test "with invalid collisions" =
  let cache =
    Cache.empty
    |> Cache.visit
         ~id:(Id.from_slug "@xvw")
         ~path:(Yocaml.Path.rel [ "users"; "xvw" ])
         ~title:"Xavier's user page"
         ~links:(ids [ "@grm"; "msp" ])
    |> Cache.visit
         ~id:(Id.from_slug "@grm")
         ~path:(Yocaml.Path.rel [ "users"; "grm" ])
         ~title:"Grim's user page"
         ~links:(ids [ "@xhtmlboi"; "xvw" ])
    |> Cache.visit
         ~id:(Id.from_slug "@xhtmlboi")
         ~path:(Yocaml.Path.rel [ "users"; "xhtmlboi" ])
         ~title:"XHTMLBoy's user page"
         ~links:(ids [ "@grm"; "msp"; "msp" ])
    |> Cache.visit
         ~id:(Id.from_slug "@msp")
         ~path:(Yocaml.Path.rel [ "users"; "msp" ])
         ~title:"Msp's user page"
         ~links:(ids [ "@grm"; "msp"; "xhtmlboi" ])
    |> Cache.visit
         ~id:(Id.from_slug "msp")
         ~path:(Yocaml.Path.rel [ "users"; "msp2" ])
         ~title:"Msp's user page"
         ~links:(ids [ "msp"; "xvw" ])
    |> Cache.visit
         ~id:(Id.from_slug "@xhtmlboi")
         ~path:(Yocaml.Path.rel [ "users"; "xhtmlboyz" ])
         ~title:"XHTMLBoy's user page"
         ~links:(ids [ "@grm"; "msp"; "msp" ])
  in
  dump cache;
  [%expect
    {|
    {"references":
     {"elements":
      [{"key": "grm", "value":
        {"fst": "./users/grm", "snd": {"fst": "Grim's user page", "snd": null}}},
      {"key": "msp", "value":
       {"fst": "./users/msp", "snd": {"fst": "Msp's user page", "snd": null}}},
      {"key": "xhtmlboi", "value":
       {"fst": "./users/xhtmlboi", "snd":
        {"fst": "XHTMLBoy's user page", "snd": null}}},
      {"key": "xvw", "value":
       {"fst": "./users/xvw", "snd": {"fst": "Xavier's user page", "snd": null}}}],
     "length": 4, "has_elements": true},
    "backlinks":
     {"elements":
      [{"key": "grm", "value":
        {"elements": ["msp", "xhtmlboi", "xvw"], "length": 3, "has_elements":
         true}},
      {"key": "msp", "value":
       {"elements": ["xhtmlboi", "xvw"], "length": 2, "has_elements": true}},
      {"key": "xhtmlboi", "value":
       {"elements": ["grm", "msp"], "length": 2, "has_elements": true}},
      {"key": "xvw", "value":
       {"elements": ["grm"], "length": 1, "has_elements": true}}],
     "length": 4, "has_elements": true},
    "collisions":
     {"elements":
      [{"key": "msp", "value":
        {"elements": ["./users/msp", "./users/msp2"], "length": 2,
        "has_elements": true}},
      {"key": "xhtmlboi", "value":
       {"elements": ["./users/xhtmlboi", "./users/xhtmlboyz"], "length": 2,
       "has_elements": true}}],
     "length": 2, "has_elements": true},
    "missing_references": null}
    |}]
;;

let%expect_test "with invalid collisions and missing references" =
  let cache =
    Cache.empty
    |> Cache.visit
         ~id:(Id.from_slug "@xvw")
         ~path:(Yocaml.Path.rel [ "users"; "xvw" ])
         ~title:"Xavier's user page"
         ~links:(ids [ "@grm"; "msp"; "foo" ])
    |> Cache.visit
         ~id:(Id.from_slug "@grm")
         ~path:(Yocaml.Path.rel [ "users"; "grm" ])
         ~title:"Grim's user page"
         ~links:(ids [ "@xhtmlboi"; "xvw" ])
    |> Cache.visit
         ~id:(Id.from_slug "@xhtmlboi")
         ~path:(Yocaml.Path.rel [ "users"; "xhtmlboi" ])
         ~title:"XHTMLBoy's user page"
         ~links:(ids [ "@grm"; "msp"; "msp"; "bar" ])
    |> Cache.visit
         ~id:(Id.from_slug "@msp")
         ~path:(Yocaml.Path.rel [ "users"; "msp" ])
         ~title:"Msp's user page"
         ~links:(ids [ "@grm"; "msp"; "xhtmlboi" ])
    |> Cache.visit
         ~id:(Id.from_slug "msp")
         ~path:(Yocaml.Path.rel [ "users"; "msp2" ])
         ~title:"Msp's user page"
         ~links:(ids [ "msp"; "xvw" ])
    |> Cache.visit
         ~id:(Id.from_slug "@xhtmlboi")
         ~path:(Yocaml.Path.rel [ "users"; "xhtmlboyz" ])
         ~title:"XHTMLBoy's user page"
         ~links:(ids [ "@grm"; "msp"; "msp" ])
  in
  dump cache;
  [%expect
    {|
    {"references":
     {"elements":
      [{"key": "grm", "value":
        {"fst": "./users/grm", "snd": {"fst": "Grim's user page", "snd": null}}},
      {"key": "msp", "value":
       {"fst": "./users/msp", "snd": {"fst": "Msp's user page", "snd": null}}},
      {"key": "xhtmlboi", "value":
       {"fst": "./users/xhtmlboi", "snd":
        {"fst": "XHTMLBoy's user page", "snd": null}}},
      {"key": "xvw", "value":
       {"fst": "./users/xvw", "snd": {"fst": "Xavier's user page", "snd": null}}}],
     "length": 4, "has_elements": true},
    "backlinks":
     {"elements":
      [{"key": "bar", "value":
        {"elements": ["xhtmlboi"], "length": 1, "has_elements": true}},
      {"key": "foo", "value":
       {"elements": ["xvw"], "length": 1, "has_elements": true}},
      {"key": "grm", "value":
       {"elements": ["msp", "xhtmlboi", "xvw"], "length": 3, "has_elements":
        true}},
      {"key": "msp", "value":
       {"elements": ["xhtmlboi", "xvw"], "length": 2, "has_elements": true}},
      {"key": "xhtmlboi", "value":
       {"elements": ["grm", "msp"], "length": 2, "has_elements": true}},
      {"key": "xvw", "value":
       {"elements": ["grm"], "length": 1, "has_elements": true}}],
     "length": 6, "has_elements": true},
    "collisions":
     {"elements":
      [{"key": "msp", "value":
        {"elements": ["./users/msp", "./users/msp2"], "length": 2,
        "has_elements": true}},
      {"key": "xhtmlboi", "value":
       {"elements": ["./users/xhtmlboi", "./users/xhtmlboyz"], "length": 2,
       "has_elements": true}}],
     "length": 2, "has_elements": true},
    "missing_references": null}
    |}]
;;
