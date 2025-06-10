type t =
  { main_title : string
  ; repository : Repository.t option
  ; branch : string
  ; owner : Identity.t option
  ; software_license : Link.t option
  ; content_license : Link.t option
  }

let validate =
  let open Yocaml.Data.Validation in
  let open Kane_util.Validation in
  record (fun o ->
    let+ main_title =
      required o [ "main_title"; "project_title"; "title" ] string
    and+ repository =
      optional o [ "repository"; "repo"; "vcs"; "vc" ] Repository.validate
    and+ branch =
      optional_or ~default:"main" o [ "branch"; "main_branch" ] string
    and+ owner =
      optional o [ "owner"; "identity"; "maintainer" ] Identity.validate
    and+ software_license =
      optional o [ "software_license"; "code_license" ] Link.validate
    and+ content_license =
      optional o [ "content_license"; "text_license"; "license" ] Link.validate
    in
    { main_title; repository; branch; owner; software_license; content_license })
;;

let normalize
      { main_title
      ; repository
      ; branch
      ; owner
      ; software_license
      ; content_license
      }
  =
  let open Yocaml.Data in
  let has_license =
    Kane_util.Option.(unit software_license <|> unit content_license)
  in
  record
    [ "main_title", string main_title
    ; "repository", option Repository.normalize repository
    ; "branch", string branch
    ; "owner", option Identity.normalize owner
    ; ( "licenses"
      , record
          [ "code", option Link.normalize software_license
          ; "content", option Link.normalize content_license
          ; Kane_util.as_opt_bool "code" software_license
          ; Kane_util.as_opt_bool "content" content_license
          ] )
    ; Kane_util.as_opt_bool "license" has_license
    ; Kane_util.as_opt_bool "repository" repository
    ; Kane_util.as_opt_bool "owner" owner
    ]
;;
