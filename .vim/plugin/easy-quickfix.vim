nnoremap <leader>cn :cnext<cr>
nnoremap <leader>cp :cprevious<cr>

function! s:GetBufferWindow(name)
  redir =>buflist
  silent! ls
  redir END
  let lines = split(buflist, '\n')
  call filter(lines, 'v:val =~ "'.a:name.'"')
  let bufnums = map(lines, 'str2nr(matchstr(v:val, "\\d\\+"))')
  for bufnum in bufnums
    let winnr = bufwinnr(bufnum)
    if winnr != -1
      return winnr
    endif
  endfor
  return -1
endfunction

function! s:GotoQuickfix()
  let winnr = <SID>GetBufferWindow("Quickfix List")
  if winnr == -1
    copen
  else
    execute winnr . 'wincmd w'
  endif
endfunction

function! s:ToggleQuickfix()
  if <SID>GetBufferWindow("Quickfix List") == -1
    copen
  else
    cclose
  endif
endfunction

nnoremap <leader>co :call <SID>ToggleQuickfix()<cr>
nnoremap <leader>cO :call <SID>GotoQuickfix()<cr>

" vim:set ts=2 sw=2:
