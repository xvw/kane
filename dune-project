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
  cmarkit
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

(package
 (name hearst_castle)
 (synopsis "A small personal Wiki engine")
 (description "A small personal Wiki engine for interconnecting pages")
 (depends
  (ocaml (>= 5.2.0))
  (kane (= :version))
  yocaml
  yocaml_yaml
  yocaml_cmarkit
  yocaml_otoml
  yocaml_syndication
  yocaml_eio))

(package
 (name kane_cli)
 (synopsis "Cmdliner helpers for invoking generator")
 (description "Use Cmdliner for building Kane's wikies")
 (depends
  (ocaml (>= 5.2.0))
  (kane (= :version))
  cmdliner))
