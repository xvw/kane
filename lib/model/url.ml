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
  ; uri : Uri.t
  }

type t =
  | Internal of Yocaml.Path.t
  | External of extern

let uri_to_data uri =
  let open Yocaml.Data in
  let scheme = Uri.scheme uri in
  let host = Uri.host uri in
  let port = Uri.port uri in
  let path = Uri.path uri in
  let query = uri |> Uri.query |> Kane_util.String.Map.of_list in
  record
    [ "scheme", option string scheme
    ; "host", option string host
    ; "port", option int port
    ; "path", string path
    ; "query", (Kane_util.String.Map.normalize (list_of string)) query
    ; Kane_util.as_opt_bool "scheme" scheme
    ; Kane_util.as_opt_bool "host" host
    ; Kane_util.as_opt_bool "port" port
    ; Kane_util.(has_field String.Map.is_empty "query" query)
    ]
;;

let validate_scheme s =
  match String.(trim @@ lowercase_ascii s) with
  | "http" -> Http
  | "https" -> Https
  | "ftp" -> Ftp
  | "gemini" -> Gemini
  | x -> Other x
;;

let validate_external s =
  let uri = Uri.of_string s in
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
       External { scheme; host; query; port; path; uri })
    fields
;;

let validate_internal =
  let open Yocaml.Data.Validation in
  Result.ok $ Yocaml.Path.from_string $ fun e -> Internal e
;;

let validate =
  Yocaml.Data.Validation.(string & (validate_external / validate_internal))
;;
