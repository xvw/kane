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
