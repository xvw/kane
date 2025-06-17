class type target_resolver = Intf.target

module Path = Yocaml.Path

class target ~parent =
  object (self : #target_resolver)
    val parent_path = parent
    method parent = parent_path
    method pages = Path.(self#parent / "pages")

    method resolve_page page =
      page |> Path.change_extension "html" |> Path.move ~into:self#pages
  end

class t
  ?(source = Path.pwd)
  ?(target = Path.rel [ "_www" ])
  ?(web_folder = Path.root)
  () =
  object (self)
    val source_path = source
    val target_path = target
    val web_folder_path = web_folder
    method bin = Path.from_string Sys.argv.(0)

    method state =
      object (self)
        method parent = Path.(source_path / ".cache")
        method cache = Path.(self#parent / "cache.csexp")
        method links = Path.(self#parent / "links")
        method backlinks_map = Path.(self#parent / "backlinks.csexp")

        method resolve_link id =
          Path.rel [ Kane_model.Id.to_string id ]
          |> Path.change_extension "csexp"
          |> Path.move ~into:self#links
      end

    method source =
      object (self)
        method parent = source_path
        method content = Path.(self#parent / "content")
        method configuration = Path.(self#parent / "configuration.toml")
        method pages = Path.(self#content / "pages")
      end

    method target = new target ~parent:target_path
    method url = new target ~parent:web_folder_path
    method common_deps = [ self#bin; self#source#configuration ]
  end
