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

class t ?(source = Path.pwd) ?target ?(web_folder = Path.root) () =
  object (self)
    val source_path = source
    val target_path = Option.value ~default:Path.(source / ".www") target
    val web_folder_path = web_folder
    method bin = Path.from_string Sys.argv.(0)

    method state =
      object (self)
        method parent = Path.(source_path / ".cache")
        method cache = Path.(self#parent / "cache.csexp")
        method ids = Path.(self#parent / "ids")
        method backlinks = Path.(self#parent / "backlinks")
        method backlinks_map = Path.(self#parent / "backlinks.csexp")

        method resolve_id_for into id =
          Path.rel [ Kane_model.Id.to_string id ]
          |> Path.change_extension "csexp"
          |> Path.move ~into

        method resolve_id = self#resolve_id_for self#ids
        method resolve_backlink = self#resolve_id_for self#backlinks
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
