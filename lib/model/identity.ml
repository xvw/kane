type t =
  { display_name : string
  ; first_name : string option
  ; last_name : string option
  ; avatar : Url.t option
  ; website : Link.t option
  ; email : Email.t option
  ; x_account : string option
  ; mastodon_account : (Url.t * string) option
  ; github_account : string option
  ; bluesky_account : string option
  ; more_accounts : Link.t list
  ; more_links : Link.t list
  ; more_emails : Email.t Kane_util.String.Map.t
  ; custom_attributes : string Kane_util.String.Map.t
  }

let make
      ~display_name
      ?first_name
      ?last_name
      ?avatar
      ?website
      ?email
      ?x_account
      ?mastodon_account
      ?github_account
      ?bluesky_account
      ?(more_accounts = [])
      ?(more_links = [])
      ?(more_emails = Kane_util.String.Map.empty)
      ?(custom_attributes = Kane_util.String.Map.empty)
      ()
  =
  { display_name
  ; first_name
  ; last_name
  ; avatar
  ; website
  ; email
  ; x_account
  ; mastodon_account
  ; github_account
  ; bluesky_account
  ; more_accounts
  ; more_links
  ; more_emails
  ; custom_attributes
  }
;;

let phrase_to_string =
  Kane_util.List.fold_lefti
    (fun i buf -> function
       | `Dot -> buf ^ "."
       | `Word (`Atom s) | `Word (`String s) | `Encoded (s, _) ->
         let sep = if Int.equal i 0 then "" else " " in
         buf ^ sep ^ s)
    ""
;;

let from_mailbox given =
  given
  |> Emile.of_string
  |> function
  | Ok Emile.{ name = Some name; local; domain } ->
    Result.map
      (fun email ->
         let display_name = phrase_to_string name in
         make ~display_name ~email ())
      (Email.from_address (local, domain))
  | Ok _ -> Yocaml.Data.Validation.fail_with ~given "Missing identity"
  | Error _ -> Yocaml.Data.Validation.fail_with ~given "Invalid mailbox"
;;

let mastodon =
  let open Yocaml.Data.Validation in
  record (fun obj ->
    let+ instance = required obj "instance" Url.validate
    and+ username =
      Kane_util.Validation.required
        obj
        []
        (string & Kane_util.String.ensure_not_blank)
    in
    instance, username)
;;

let validate =
  let open Yocaml.Data.Validation in
  (string & from_mailbox)
  / record (fun obj ->
    let open Kane_util.Validation in
    let+ display_name =
      required
        obj
        [ "display_name"; "username"; "name"; "id"; "user_name" ]
        (string & Kane_util.String.ensure_not_blank)
    and+ first_name =
      optional
        obj
        [ "first_name"; "firstname" ]
        (string & Kane_util.String.ensure_not_blank)
    and+ last_name =
      optional
        obj
        [ "last_name"; "lastname" ]
        (string & Kane_util.String.ensure_not_blank)
    and+ avatar = optional obj [ "avatar" ] Url.validate
    and+ website = optional obj [ "site"; "website"; "url" ] Link.validate
    and+ email = optional obj [ "email"; "mail" ] Email.validate
    and+ x_account =
      optional obj [ "x"; "twitter"; "x_account"; "twitter_account" ] string
    and+ github_account =
      optional obj [ "github"; "gh"; "github_account"; "gh_account" ] string
    and+ bluesky_account =
      optional
        obj
        [ "bluesky"; "bsky"; "bluesky_account"; "bsky_account" ]
        string
    and+ mastodon_account =
      optional obj [ "mastodon"; "mastodon_account" ] mastodon
    and+ more_accounts =
      optional_or
        ~default:[]
        obj
        [ "more_accounts"; "accounts" ]
        (list_of Link.validate)
    and+ more_links =
      optional_or
        ~default:[]
        obj
        [ "more_links"; "links" ]
        (list_of Link.validate)
    and+ more_emails =
      optional_or
        ~default:Kane_util.String.Map.empty
        obj
        [ "more_emails"; "emails" ]
        (Kane_util.String.Map.validate Email.validate)
    and+ custom_attributes =
      optional_or
        ~default:Kane_util.String.Map.empty
        obj
        [ "attributes"; "kv"; "data"; "custom"; "custom_attributes" ]
        (Kane_util.String.Map.validate string)
    in
    make
      ~display_name
      ?first_name
      ?last_name
      ?avatar
      ?website
      ?email
      ?x_account
      ?bluesky_account
      ?github_account
      ?mastodon_account
      ~more_accounts
      ~more_links
      ~more_emails
      ~custom_attributes
      ())
;;

let normalize
      { display_name
      ; first_name
      ; last_name
      ; avatar
      ; website
      ; email
      ; x_account
      ; mastodon_account
      ; github_account
      ; bluesky_account
      ; more_accounts
      ; more_links
      ; more_emails
      ; custom_attributes
      }
  =
  let open Yocaml.Data in
  let accounts =
    Kane_util.Option.(
      unit x_account
      <|> unit mastodon_account
      <|> unit github_account
      <|> unit bluesky_account
      <|> guard (not (List.is_empty more_accounts)))
  in
  record
    [ "display_name", string display_name
    ; "first_name", option string first_name
    ; "last_name", option string last_name
    ; "avatar", option Url.normalize avatar
    ; "website", option Link.normalize website
    ; "email", option Email.normalize email
    ; ( "accounts"
      , record
          [ "x", option string x_account
          ; "bluesky", option string bluesky_account
          ; ( "mastodon"
            , option
                (fun (instance, username) ->
                   record
                     [ "instance", Url.normalize instance
                     ; "username", string username
                     ])
                mastodon_account )
          ; "github", option string github_account
          ; "other", list_of Link.normalize more_accounts
          ; Kane_util.as_opt_bool "x" x_account
          ; Kane_util.as_opt_bool "bluesky" bluesky_account
          ; Kane_util.as_opt_bool "mastodon" mastodon_account
          ; Kane_util.as_opt_bool "github" github_account
          ; Kane_util.as_list_bool "other" more_accounts
          ] )
    ; "links", list_of Link.normalize more_links
    ; "emails", Kane_util.String.Map.normalize Email.normalize more_emails
    ; "attributes", Kane_util.String.Map.normalize string custom_attributes
    ; Kane_util.as_opt_bool "accounts" accounts
    ; Kane_util.as_opt_bool "first_name" first_name
    ; Kane_util.as_opt_bool "last_name" last_name
    ; Kane_util.as_opt_bool "avatar" avatar
    ; Kane_util.as_opt_bool "website" website
    ; Kane_util.as_opt_bool "email" email
    ; Kane_util.as_list_bool "links" more_links
    ; Kane_util.has_field Kane_util.String.Map.is_empty "emails" more_emails
    ; Kane_util.has_field
        Kane_util.String.Map.is_empty
        "attributes"
        custom_attributes
    ]
;;
