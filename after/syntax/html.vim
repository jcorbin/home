" Language:    GorillaScript
" Maintainer:  "UnCO" Lin <undercooled _aT_ lavabit _dOt_ com>
" URL:         http://github.com/unc0/vim-gorilla-script
" License:     WTFPL

" Syntax highlighting for text/gorillascript script tags
syn include @htmlGorillaScript syntax/gorilla.vim
syn region coffeeScript start=+<script [^>]*type *=[^>]*text/gorillascript[^>]*>+
\                       end=+</script>+me=s-1 keepend
\                       contains=@htmlGorillaScript,htmlScriptTag,@htmlPreproc
\                       containedin=htmlHead
