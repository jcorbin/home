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

" searching {{{
set ignorecase " Do case insensitive matching...
set smartcase  " ...but only if the user didn't explicitly case
set hlsearch   " highlight while searching

" disable hlsearch in insert mode
augroup hlsearch
  autocmd InsertEnter * :setlocal nohlsearch
  autocmd InsertLeave * :setlocal   hlsearch
augroup END
" }}}

" Save undo files in central location {{{
if has("persistent_undo")
  set undofile
  set undodir=$HOME/.nvim/undo
  if !isdirectory(&undodir) && exists("*mkdir")
    call mkdir(&undodir, "p", 0700)
  endif
endif
" }}}

" Save swap files in central location {{{
set swapsync=
set directory=$HOME/.nvim/swap
if exists("*mkdir") && !isdirectory(&directory)
  call mkdir(&directory, "p", 0700)
endif
" }}}

" abbreviations {{{
augroup filetype_abbrs
  autocmd FileType javascript :iabbrev <buffer> vst var self = this;
augroup END
" }}}

" vim:set foldmethod=marker foldlevel=0 ts=2 sw=2 expandtab:
