function! s:CasedRegex(regex)
    return (&ignorecase ?  '\c' : '\C') . a:regex
endfunction

if !exists("s:used_2match")
    let s:used_2match = 0
endif

if !exists("s:used_3match")
    let s:used_3match = 0
endif

function! s:SetMatch(n, regex)
    if a:n == 2
        let s:used_2match = 1
    elseif a:n == 3
        let s:used_3match = 1
        NoMatchParen
    endif
    execute a:n . "match Match" . a:n . " /" . a:regex . "/"
endfunction

function! s:MatchOff()
    match

    if s:used_2match
        let s:used_2match = 0
        2match
    endif

    if s:used_3match
        let s:used_3match = 0
        DoMatchParen
        3match
    endif
endfunction

nnoremap <leader>/  :call <SID>SetMatch(1, <SID>CasedRegex(@/))<cr>
nnoremap <leader>2/ :call <SID>SetMatch(2, <SID>CasedRegex(@/))<cr>
nnoremap <leader>3/ :call <SID>SetMatch(3, <SID>CasedRegex(@/))<cr>
nnoremap <leader><s-space> :nohlsearch<cr>:call <SID>MatchOff()<cr>
