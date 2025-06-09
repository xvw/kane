type with_user =
  { user : string
  ; repository : string
  }

let github_uri = Url.https "github.com"
let gitlab_uri = Url.https "gitlab.com"
let tangled_uri = Url.https "tangled.sh"

module Gitlab = struct
  type t =
    | User of with_user
    | Org of
        { name : string
        ; project : string
        ; repository : string
        }
end

type t =
  | Github of with_user
  | Gitlab of Gitlab.t
  | Tangled of with_user

let home = function
  | Github { user; repository } ->
    Url.resolve github_uri (Yocaml.Path.abs [ user; repository ])
  | Gitlab (User { user; repository }) ->
    Url.resolve gitlab_uri (Yocaml.Path.abs [ user; repository ])
  | Tangled { user; repository } ->
    Url.resolve tangled_uri (Yocaml.Path.abs [ "@" ^ user; repository ])
  | Gitlab (Org { name; project; repository }) ->
    Url.resolve gitlab_uri (Yocaml.Path.abs [ name; project; repository ])
;;

let bug_tracker = function
  | (Tangled _ | Github _) as repo ->
    Url.resolve (home repo) Yocaml.Path.(rel [ "issues" ])
  | Gitlab _ as repo ->
    Url.resolve (home repo) Yocaml.Path.(rel [ "-"; "issues" ])
;;

let repo_from_uri path =
  let open Yocaml.Data in
  match path with
  | "" :: user :: repository :: ([ "" ] | [])
  | user :: repository :: ([ "" ] | []) ->
    record [ "user", string user; "repository", string repository ]
  | "" :: name :: project :: repository :: ([ "" ] | [])
  | name :: project :: repository :: ([ "" ] | []) ->
    record
      [ "organization", string name
      ; "project", string project
      ; "repository", string repository
      ]
  | _ -> record []
;;

let remove_at given =
  given
  |> Kane_util.String.remove_first_char_when (Char.equal '@')
  |> Kane_util.String.ensure_not_blank
;;

let validate_path =
  let open Yocaml.Data.Validation in
  record (fun o ->
    let+ user =
      required o "user" (string & Kane_util.String.ensure_not_blank & remove_at)
    and+ repository =
      required o "repository" (string & Kane_util.String.ensure_not_blank)
    in
    { user; repository })
;;

let validate_gitlab =
  let open Yocaml.Data.Validation in
  (validate_path $ fun x -> Gitlab.User x)
  / record (fun o ->
    let+ name = required o "name" (string & Kane_util.String.ensure_not_blank)
    and+ project =
      required o "project" (string & Kane_util.String.ensure_not_blank)
    and+ repository =
      required o "repository" (string & Kane_util.String.ensure_not_blank)
    in
    Gitlab.Org { name; project; repository })
;;

let from_uri given =
  let uri = Uri.of_string given in
  let path = repo_from_uri (Uri.path uri |> String.split_on_char '/') in
  match Uri.host uri with
  | Some "github.com" -> Result.map (fun x -> Github x) (validate_path path)
  | Some "tangled.sh" -> Result.map (fun x -> Tangled x) (validate_path path)
  | Some "gitlab.com" -> Result.map (fun x -> Gitlab x) (validate_gitlab path)
  | _ -> Yocaml.Data.Validation.fail_with ~given "Unknown repository uri"
;;

let from_string given =
  match
    given
    |> String.split_on_char '/'
    |> List.map (fun x -> x |> String.trim |> String.lowercase_ascii)
  with
  | ("github" | "github.com" | "gh") :: xs ->
    let path = repo_from_uri xs in
    Result.map (fun x -> Github x) (validate_path path)
  | ("tangled" | "tangled.sh") :: xs ->
    let path = repo_from_uri xs in
    Result.map (fun x -> Tangled x) (validate_path path)
  | ("gitlab" | "gitlab.com") :: xs ->
    let path = repo_from_uri xs in
    Result.map (fun x -> Gitlab x) (validate_gitlab path)
  | _ -> Yocaml.Data.Validation.fail_with ~given "Unknown repository scheme"
;;

let validate =
  let open Yocaml.Data.Validation in
  string & (from_string / from_uri)
;;

let kind_of = function
  | Github _ -> "github"
  | Gitlab _ -> "gitlab"
  | Tangled _ -> "tangled"
;;

let is_org = function
  | Gitlab (Org _) -> true
  | Github _ | Gitlab _ | Tangled _ -> false
;;

let comp = function
  | Github { user; repository }
  | Tangled { user; repository }
  | Gitlab (User { user; repository }) -> [ user; repository ]
  | Gitlab (Org { name; project; repository }) -> [ name; project; repository ]
;;

let clone_http repo =
  match repo with
  | Tangled _ -> repo |> home |> Url.to_string
  | repo ->
    repo
    |> home
    |> Url.on_path (Yocaml.Path.change_extension ".git")
    |> Url.to_string
;;

let clone_ssh _ = "<to-be-done>"

let normalize repo =
  let open Yocaml.Data in
  let home = home repo in
  record
    [ "kind", string @@ kind_of repo
    ; "is_organization", bool @@ is_org repo
    ; "components", list_of string @@ comp repo
    ; "homepage", Url.normalize home
    ; "bug-tracker", Url.normalize @@ bug_tracker repo
    ; ( "clone"
      , record
          [ "https", string @@ clone_http repo
          ; "ssh", string @@ clone_ssh repo
          ] )
    ]
;;
