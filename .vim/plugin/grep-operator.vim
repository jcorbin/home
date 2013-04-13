" natural progression of the grep operator from Learn Vimscript The Hard Way
" by Steve Losh; major differences:
" - uses pattern documented in map-operator:
" -- protect against user selection setting
" -- silent yanking
" - echos the path being grepped in, makes it a variable in case I can find
"   some sane way to allow this to be optionally specified by perhaps a
"   different binding
" - supports line-wise greppnig to specify multiple patterns; think of this as
"   a natural mapping of grep -f... in fact I'd like to figure out if I can
"   pass patterns using a filehandle rather than munging them into an
"   alternation

nnoremap <leader>* :set operatorfunc=<SID>GrepOperator<cr>g@
vnoremap <leader>* :<c-u>call <SID>GrepOperator(visualmode(), 1)<cr>

function! s:GrepOperator(type, ...)
    let reg_save = @@
    let sel_save = &selection

    let path = getcwd()
    let &selection = "inclusive"

    if a:0
        " Invoked from Visual mode, use '< and '> marks.
        silent execute "normal! `<" . a:type . "`>y"
    elseif a:type ==# 'line'
        silent execute "normal! `[V`]y"
    elseif a:type ==# 'block'
        silent execute "normal! `[<C-V>`]y"
    else
        silent execute "normal! `[v`]y"
    endif

    let patterns = split(@@, '\r\?\n')
    call map(patterns, 'substitute(v:val, "\\v^\\s+|\\s+$", "", "g")')
    call filter(patterns, 'strlen(v:val) > 0')

    echom "Grepping for" join(patterns, '|') "in" path
    silent execute "grep! -R" shellescape(join(patterns, '\\|')) path
    copen

    let &selection = sel_save
    let @@ = reg_save
endfunction
