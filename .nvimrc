" plugins {{{
" https://github.com/junegunn/vim-plug
call plug#begin('~/.nvim/plugged')

call plug#end()
" }}}

" Options {{{

set cursorline
set expandtab
set list
set scrolloff=3 " Try to keep 3 lines after cursor
set splitbelow
set splitright
set virtualedit=all
set wildmode=longest,list:longest

let g:netrw_liststyle = 3

set tabstop=4
set shiftwidth=4
set smartindent

" }}}

" vim:set foldmethod=marker foldlevel=0 ts=2 sw=2 expandtab:
