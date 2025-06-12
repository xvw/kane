let pp spp ppf = function
  | Ok x -> Format.fprintf ppf "Ok: %a" spp x
  | Error error ->
    let e =
      Yocaml.(
        Eff.Provider_error
          (Required.Validation_error { entity = "test"; error }))
    in
    Format.fprintf
      ppf
      "Error: %a"
      (fun ppf x ->
         Yocaml.Diagnostic.exception_to_diagnostic
           ~in_exception_handler:false
           ppf
           x)
      e
;;

let validation spp x = x |> Format.asprintf "%a" (pp spp) |> print_endline

let normalization normalize x =
  x
  |> validation (fun ppf x ->
    x |> normalize |> Format.fprintf ppf "%a" Yocaml.Data.pp)
;;

let from (module D : Intf.DUMP) subject =
  subject |> D.validate |> normalization D.normalize
;;
