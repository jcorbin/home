nnoremap <leader>f :call FoldColumnCycle()<cr>

function! FoldColumnCycle()
  " TODO: may be better to save old value and just toggle off and back to
  " previous if not 1 or 4
  if ! &foldcolumn
    setlocal foldcolumn=1
  elseif &foldcolumn >= 1 && &foldcolumn < 4
    setlocal foldcolumn=4
  else
    setlocal foldcolumn=0
  endif
endfunction

" vim:set ts=2 sw=2 expandtab:
