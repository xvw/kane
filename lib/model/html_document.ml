class t ?(title_prefix = "") ~title () =
  object (_ : #Intf.html_document)
    val title_value = title
    method title = title_prefix ^ title_value
  end
