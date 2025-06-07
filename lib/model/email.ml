type t =
  { local : string
  ; domain : string list
  }

let make local domain = { local; domain }

let concat_local =
  Kane_util.String.concat_with
    (function
      | `String a | `Atom a -> a)
    "."
;;

let concat_domain = String.concat "."

let from_address given =
  match given with
  | local, (`Domain domain, []) ->
    (* We do not support complicated email scheme. *)
    let local = concat_local local in
    Ok (make local domain)
  | _ ->
    let given = Emile.address_to_string given in
    Yocaml.Data.Validation.fail_with ~given "Unsupported email scheme"
;;

let from_string given =
  given
  |> Emile.address_of_string
  |> function
  | Ok address -> from_address address
  | Error (`Invalid (a, b)) ->
    let err = Format.asprintf "Invalid `%s%s`" a b in
    Yocaml.Data.Validation.fail_with ~given err
;;

let validate =
  let open Yocaml.Data.Validation in
  string & from_string
;;

let normalize { local; domain } =
  let open Yocaml.Data in
  let cdomain = concat_domain domain in
  let address = local ^ "@" ^ cdomain in
  record
    [ "address", string address
    ; "local", string local
    ; "domain", string cdomain
    ; "domain_fragments", list_of string domain
    ; ( "address_md5"
      , string
          (Digest.to_hex
           @@ Digest.string Stdlib.String.(lowercase_ascii @@ trim address)) )
    ]
;;
