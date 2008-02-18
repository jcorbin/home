" Vim script file                                           vim600:fdm=marker:
" FileType:	HTML
" Maintainer:	Devin Weaver <vim@tritarget.com>
" Location:	http://www.vim.org/scripts/script.php?script_id=301

" This is a wrapper script to add extra html support to xml documents.
" Original script can be seen in xml-plugin documentation.

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
" Don't set 'b:did_ftplugin = 1' because that is xml.vim's responsability.

let b:html_mode = 1

if exists("*HtmlAttribCallback")
  delfunction HtmlAttribCallback
endif

function HtmlAttribCallback( xml_tag )
    if a:xml_tag ==? "table"
  return "cellpadding=\"0\" cellspacing=\"0\" border=\"0\""
    elseif a:xml_tag ==? "form"
  return "name=\"\" action=\"\" method=\"post\""
    elseif a:xml_tag ==? "label"
  return "for=\"\""
    elseif a:xml_tag ==? "input"
  return "type=\"\" id=\"\" name=\"\""
    elseif a:xml_tag ==? "html"
  return "xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\""
    elseif a:xml_tag ==? "script"
  return "language=\"javascript\" type=\"text/javascript\""
    elseif a:xml_tag ==? "td"
  return "valign=\"top\""
    elseif a:xml_tag ==? "link"
  return "href=\"\" rel=\"StyleSheet\" type=\"text/css\""
    elseif a:xml_tag ==? "frame"
  return "name=\"\" src=\"/\" scrolling=\"auto\" noresize"
    elseif a:xml_tag ==? "frameset"
  return "rows=\"0,*\" cols=\"*,0\" border=\"0\""
    elseif a:xml_tag ==? "img"
  return "src=\"\" width=\"0\" height=\"0\" border=\"0\" alt=\"\""
    elseif a:xml_tag ==? "style"
  return "type=\"text/css\""
    else
  return 0
    endif
endfunction

" On to loading xml.vim
runtime ftplugin/xml.vim
