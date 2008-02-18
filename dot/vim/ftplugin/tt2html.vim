if exists("b:did_ftplugin")
  finish
endif

let b:html_mode = 1

if !exists("*HtmlAttribCallback")
  function HtmlAttribCallback( xml_tag )
      if a:xml_tag ==? "table"
    return "cellpadding=\"0\" cellspacing=\"0\" border=\"0\""
      elseif a:xml_tag ==? "html"
    return "xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\""
      elseif a:xml_tag ==? "script"
    return "language=\"javascript\" type=\"text/javascript\""
      elseif a:xml_tag ==? "td"
    return "valign=\"top\""
      elseif a:xml_tag ==? "link"
    return "href=\"\" rel=\"StyleSheet\" type=\"text/css\""
      elseif a:xml_tag ==? "frame"
    return "name=\"NAME\" src=\"/\" scrolling=\"auto\" noresize"
      elseif a:xml_tag ==? "frameset"
    return "rows=\"0,*\" cols=\"*,0\" border=\"0\""
      elseif a:xml_tag ==? "img"
    return "src=\"\" width=\"0\" height=\"0\" border=\"0\" alt=\"\""
      else
    return 0
      endif
  endfunction
endif

runtime ftplugin/xml.vim
runtime syntax/tt2html.vim
