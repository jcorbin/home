" Language:    GorillaScript
" Maintainer:  "UnCO" Lin <undercooled _aT_ lavabit _dOt_ com>
" URL:         http://github.com/unc0/vim-gorilla-script
" License:     WTFPL

autocmd BufNewFile,BufRead *.gs,Gorkfile set filetype=gorilla

function! s:DetectGorilla()
    if getline(1) =~ '^#!.*\<gorilla\>'
        setfiletype gorilla
    endif
endfunction

autocmd BufRead * call s:DetectGorilla()
