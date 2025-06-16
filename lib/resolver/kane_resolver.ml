module Path = Yocaml.Path

class t ?(source = Path.rel []) ?(target = Path.rel [ "_www" ]) () =
  object
    val source_path = source
    val target_path = target

    method source =
      object (self)
        method root = source_path
        method content = Path.(source_path / "content")
        method pages = Path.(self#content / "pages")
      end

    method target =
      object (self)
        method root = target_path
        method pages = Path.(target_path / "pages")

        method resolve_page page =
          page |> Path.change_extension "html" |> Path.move ~into:self#pages
      end
  end
