type scheme =
  | Http
  | Https
  | Ftp
  | Gemini
  | Other of string

type extern =
  { scheme : scheme
  ; host : string
  ; path : Yocaml.Path.t
  ; port : int option
  ; query : string list Kane_util.String.Map.t
  }

type t =
  | Internal of Yocaml.Path.t * Uri.t
  | External of extern * Uri.t

let normalize_repr
      ?scheme
      ?host
      ?port
      ?(query = Kane_util.String.Map.empty)
      f
      path
  =
  let open Yocaml.Data in
  record
    [ "scheme", option string scheme
    ; "host", option string host
    ; "port", option int port
    ; "path", f path
    ; "query", (Kane_util.String.Map.normalize (list_of string)) query
    ; Kane_util.as_opt_bool "scheme" scheme
    ; Kane_util.as_opt_bool "host" host
    ; Kane_util.as_opt_bool "port" port
    ; Kane_util.(has_field String.Map.is_empty "query" query)
    ]
;;

let uri_to_data uri =
  let open Yocaml.Data in
  let scheme = Uri.scheme uri in
  let host = Uri.host uri in
  let port = Uri.port uri in
  let path = Uri.path uri in
  let query = uri |> Uri.query |> Kane_util.String.Map.of_list in
  normalize_repr ?scheme ?host ?port ~query string path
;;

let validate_scheme s =
  match String.(trim @@ lowercase_ascii s) with
  | "http" -> Http
  | "https" -> Https
  | "ftp" -> Ftp
  | "gemini" -> Gemini
  | x -> Other x
;;

let validate_external uri =
  let fields = uri_to_data uri in
  let open Yocaml.Data.Validation in
  record
    (fun o ->
       let+ host = required o "host" (string & Kane_util.String.ensure_not_blank)
       and+ port = optional o "port" (int & positive)
       and+ path = required o "path" (string $ Yocaml.Path.from_string)
       and+ query =
         optional_or
           ~default:Kane_util.String.Map.empty
           o
           "query"
           (Kane_util.String.Map.validate (list_of string))
       and+ scheme =
         required
           o
           "scheme"
           (string & Kane_util.String.ensure_not_blank $ validate_scheme)
       in
       External ({ scheme; host; query; port; path }, uri))
    fields
;;

let validate_internal uri =
  let open Yocaml.Data.Validation in
  (Result.ok $ Uri.path $ Yocaml.Path.from_string $ fun e -> Internal (e, uri))
    uri
;;

let validate =
  Yocaml.Data.Validation.(
    string $ Uri.of_string & (validate_external / validate_internal))
;;

let uri = function
  | External (_, uri) | Internal (_, uri) -> uri
;;

let scheme_to_string = function
  | Http -> "http"
  | Https -> "https"
  | Ftp -> "ftp"
  | Gemini -> "gemini"
  | Other x -> x
;;

let target_of url = url |> uri |> Uri.to_string

let is_internal = function
  | Internal _ -> true
  | _ -> false
;;

let scheme = function
  | Internal _ -> None
  | External ({ scheme; _ }, _) -> Some scheme
;;

let is_external x = not (is_internal x)

let compact_target f = function
  | Internal (p, _) -> Yocaml.Path.to_string p
  | External ({ scheme; host; path; port; query }, _) ->
    f scheme host port query path
;;

let repr_domain _ host _ _ _ = host
let repr_domain_with_path _ host _ _ path = host ^ Yocaml.Path.to_string path

let repr url =
  let open Yocaml.Data in
  record
    [ "full", string (target_of url)
    ; "domain", string (compact_target repr_domain url)
    ; "domain_with_path", string (compact_target repr_domain_with_path url)
    ]
;;

let normalize url =
  let is_internal = is_internal url in
  let open Yocaml.Data in
  record
    [ "target", string (target_of url)
    ; "is_internal", bool is_internal
    ; "is_external", bool (not is_internal)
    ; "kind", string (if is_internal then "internal" else "external")
    ; "repr", repr url
    ; "uri", url |> uri |> uri_to_data
    ; "scheme", option (fun x -> x |> scheme_to_string |> string) (scheme url)
    ]
;;
