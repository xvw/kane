class t ?(backlinks = Id.Map.empty) ?(internal_links = Id.Map.empty) () =
  object (self : #Intf.backlinks)
    val backlinks_value = backlinks
    val internal_links_value = internal_links
    method backlinks = backlinks_value
    method internal_links = internal_links_value
    method set_backlinks new_backlinks = {<backlinks_value = new_backlinks>}
    method set_internal_links new_set = {<internal_links_value = new_set>}

    method all =
      Id.Map.union (fun _ a _ -> Some a) self#backlinks self#internal_links
  end

class attached ?(backlinks = new t ()) () =
  object (_ : #Intf.with_backlinks)
    val value = backlinks
    method get = value
    method set x = {<value = x>}
  end

let entity_name = "Backlinks"
let neutral = Ok (new t ())

let validate =
  let open Yocaml.Data.Validation in
  record (fun fields ->
    let open Kane_util.Validation in
    let+ backlinks =
      optional
        fields
        [ "backlinks"; "back"; "back_links" ]
        (Id.Map.validate Relation.validate)
    and+ internal_links =
      optional
        fields
        [ "internal_links"; "links"; "internal" ]
        (Id.Map.validate Relation.validate)
    in
    new t ?backlinks ?internal_links ())
;;

let normalize (p : t) =
  let open Yocaml.Data in
  record
    [ "backlinks", Id.Map.normalize Relation.normalize p#backlinks
    ; "internal_links", Id.Map.normalize Relation.normalize p#internal_links
    ]
;;

let dump p =
  p |> normalize |> Yocaml.Data.to_sexp |> Yocaml.Sexp.Canonical.to_string
;;
