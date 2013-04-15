" use relativenumber in vim 7.3+
if version >= 703
    function! CycleNumbering()
        " (off number relativenumber)
        if &number
            setlocal relativenumber
        elseif &relativenumber
            setlocal norelativenumber
        else
            setlocal number
        endif
    endfunction

    " start out with relative numbering on
    set relativenumber

    nnoremap <leader># :call CycleNumbering()<cr>

" fallback to just using number in vim <7.3
else
    " start out with numbering on
    set number

    nnoremap <leader># :setlocal number!<cr>
endif

" vim:set ts=2 sw=2 expandtab:
