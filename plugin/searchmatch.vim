" searchmatch.vim - easier use of match and co
" Maintainer: Joshua T Corbin
" URL:        https://github.com/jcorbin/vim-searchmatch
" Version:    0.9.0

if exists("g:loaded_searchmatch") || &cp
  finish
endif
let g:loaded_searchmatch = 1

function! s:cased_regex(regex)
  return (&ignorecase ?  '\c' : '\C') . a:regex
endfunction

if !exists("s:used_1match")
  let s:used_1match = 0
endif

if !exists("s:used_2match")
  let s:used_2match = 0
endif

if !exists("s:used_3match")
  let s:used_3match = 0
endif

if !exists("s:disabled_matchparen")
  let s:disabled_matchparen = 0
endif

function! s:setup_highlight_defaults()
  highlight default link Match1 ErrorMsg
  highlight default link Match2 DiffDelete
  highlight default link Match3 DiffAdd
endfunction

augroup searchmatch
autocmd ColorScheme * call <SID>setup_highlight_defaults()
augroup END

call <SID>setup_highlight_defaults()

function! s:set_match(n, regex)
  execute a:n . "match Match" . a:n . " /" . a:regex . "/"
  if a:n == 1
    let s:used_1match = 1
  elseif a:n == 2
    let s:used_2match = 1
  elseif a:n == 3
    let s:used_3match = 1
    if exists("g:loaded_matchparen")
      let s:disabled_matchparen = 1
      NoMatchParen
    endif
  endif
endfunction

function! s:reset_match()
  if s:used_1match
    match
    let s:used_1match = 0
  endif

  if s:used_2match
    2match
    let s:used_2match = 0
  endif

  if s:used_3match
    3match
    let s:used_3match = 0
    if s:disabled_matchparen
      if !exists("g:loaded_matchparen")
        DoMatchParen
      endif
      let s:disabled_matchparen = 0
    endif
  endif
endfunction

command! SearchMatch1     :call <SID>set_match(1, <SID>cased_regex(@/))
command! SearchMatch2     :call <SID>set_match(2, <SID>cased_regex(@/))
command! SearchMatch3     :call <SID>set_match(3, <SID>cased_regex(@/))
command! SearchMatchReset :call <SID>reset_match()

if !exists("g:searchmatch_nomap") && mapcheck("<leader>/", "n") == ""
  nmap <leader>/  :SearchMatch1<CR>
  nmap <leader>2/ :SearchMatch2<CR>
  nmap <leader>3/ :SearchMatch3<CR>
  nmap <leader>-/ :SearchMatchReset<CR>
endif
