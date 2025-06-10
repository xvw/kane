type t =
  { main_title : string
  ; main_url : Url.t
  ; repository : Repository.t option
  ; branch : string
  ; owner : Identity.t option
  ; software_license : Link.t option
  ; content_license : Link.t option
  ; main_locale : string
  }

let neutral =
  { main_title = "untitled"
  ; main_url = Url.http "localhost"
  ; repository = None
  ; branch = "main"
  ; owner = None
  ; software_license = None
  ; content_license = None
  ; main_locale = "en_US"
  }
;;

let validate =
  let open Yocaml.Data.Validation in
  let open Kane_util.Validation in
  record (fun o ->
    let+ main_title =
      required o [ "main_title"; "project_title"; "title" ] string
    and+ main_url = required o [ "url"; "main_url"; "base_url" ] Url.validate
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
    and+ main_locale =
      optional_or ~default:"en_US" o [ "locale"; "lang" ] string
    in
    { main_title
    ; main_url
    ; repository
    ; branch
    ; owner
    ; software_license
    ; content_license
    ; main_locale
    })
;;

let normalize
      { main_title
      ; repository
      ; branch
      ; owner
      ; software_license
      ; content_license
      ; main_url
      ; main_locale
      }
  =
  let open Yocaml.Data in
  let has_license =
    Kane_util.Option.(unit software_license <|> unit content_license)
  in
  record
    [ "main_title", string main_title
    ; "main_url", Url.normalize main_url
    ; "main_locale", string main_locale
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

let meta_tags { main_title; owner; main_locale; _ } =
  Html_meta.
    [ make ~name:"og:site_name" ~content:main_title
    ; make ~name:"og:locale" ~content:main_locale
    ]
  @ Html_meta.map_option Identity.meta_tags owner
;;
