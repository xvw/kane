(** All the actions that build the state of the encyclopaedia. A state
    contains intermediate artefacts that enable the construction of
    concrete pages, notably the resolution between IDs and backlinks. *)

(** The general idea is to build intermediate files to guarantee
    maximum incrementality in [server] mode. *)

(** {1 Global flow}

    The general flow works like this:

    - {!val:index_links} will build a database of identifiers with
      their url, title, potential synopsis and internal links to other
      identifiers.

    - {!val:index_backlinks} Will build a single file that depends on
      the identifier database, which will be used as dependencies to
      create individual files (which will be used as dependencies to
      create each page/element that requires the cache to be
      calculated).

    - {!val:index_each_backlinks} Will build a file for each
      identifier referencing the backlinks based on the global database
      of backlinks. *)

(** The entry point of the model. *)
val indexation
  :  resolver:Kane_resolver.t
  -> configuration:Kane_model.Configuration.t
  -> Yocaml.Action.t

(** {1 Actions}

    All intermediate actions. *)

val index_ids
  :  resolver:Kane_resolver.t
  -> configuration:Kane_model.Configuration.t
  -> Yocaml.Action.t

val index_backlinks : resolver:Kane_resolver.t -> Yocaml.Action.t
val index_each_backlinks : resolver:Kane_resolver.t -> Yocaml.Action.t

(** {1 Notes}

    TODO: For the moment, the generator does not yet support incrementality,
    but the separation of actions will enable a handler to be composed
    for generation and a handler for incremental construction during
    the serve. *)
