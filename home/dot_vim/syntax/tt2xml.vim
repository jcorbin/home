runtime! syntax/xml.vim
unlet b:current_syntax

so <sfile>:p:h/tt2.vim
unlet b:current_syntax
syn cluster xmlPreProc add=@tt2_top_cluster

