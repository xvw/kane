class t ?(backlinks = []) () =
  object (_ : #Intf.with_backlinks)
    val backlinks_value = backlinks
    method backlinks = backlinks_value
    method set_backlinks new_backlinks = {<backlinks_value = new_backlinks>}
  end
