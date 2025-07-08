let source ?(default = Yocaml.Path.rel []) () =
  let doc = "Source directory" in
  let arg = Cmdliner.Arg.info ~doc [ "source"; "input"; "content"; "S"; "I" ] in
  Cmdliner.Arg.(value @@ opt Conv.path default arg)
;;

let target ?(default = Yocaml.Path.rel [ "_www" ]) () =
  let doc = "Target directory" in
  let arg = Cmdliner.Arg.info ~doc [ "target"; "output"; "T"; "I" ] in
  Cmdliner.Arg.(value @@ opt Conv.path default arg)
;;

let port ?(default = 8888) () =
  let doc = "The development server's listening port" in
  let arg = Cmdliner.Arg.info ~doc [ "port"; "P" ] in
  Cmdliner.Arg.(value @@ opt Conv.port default arg)
;;

let log_level ?(default = `Debug) () =
  let doc = "The log-level of the application running" in
  let arg = Cmdliner.Arg.info ~doc [ "log-level"; "level"; "log" ] in
  Cmdliner.Arg.(value @@ opt Conv.log_level default arg)
;;
