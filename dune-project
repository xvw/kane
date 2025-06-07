(lang dune 3.16)
(name kane)
(version dev)
(generate_opam_files)
(executables_implicit_empty_intf)

(source (github xvw/kane))
(license MIT)
(authors "Xavier Van de Woestyne <xaviervdw@gmail.com>")
(maintainers "Xavier Van de Woestyne <xaviervdw@gmail.com>")

(package
 (name kane)
 (synopsis "A codex of features for YOCaml")
 (description "A set of pre-coded features for YOCaml to make bootstrapping a static site easier")
 (depends
  (ocaml (>= 5.2.0))
  uri
  emile 
  yocaml
  yocaml_cmarkit
  yocaml_yaml
  yocaml_otoml
  yocaml_syndication
  ppx_expect
  (utop :with-dev-setup)
  (ocamlformat :with-dev-setup)
  (ocp-indent :with-dev-setup)
  (merlin :with-dev-setup)
  (ocaml-lsp-server :with-dev-setup)))
 
