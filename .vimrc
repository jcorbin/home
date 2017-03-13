" plugins {{{

" setup vim-plug, downloading it if needed
" see https://github.com/junegunn/vim-plug
let $VIMHOME=expand('<sfile>:p:h')
if $VIMHOME == $HOME
  let $VIMHOME=$HOME.'/.vim'
endif
if empty(glob($VIMHOME.'/autoload/plug.vim'))
    silent !curl -fLo $VIMHOME/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin($VIMHOME.'/plugged')

" better defaults out of the box
Plug 'tpope/vim-sensible'

" complements builtin NetRW mode for easier file navigation
Plug 'tpope/vim-vinegar'

" Adds a new text object for "surrounding" things
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'

" Better statusline
Plug 'bling/vim-airline'

call plug#end()
" }}}

" Save swap files in one place... {{{
" ...instead of beside the file being edited. This ends up being kinder to
" things like SCM and remote file systems.
set directory=$VIMHOME/swap
if exists("*mkdir") && !isdirectory(&directory)
  call mkdir(&directory, "p", 0700)
endif
" }}}

" Persistent undo (vim 7.3+) {{{
" Saves undo history, in a similar location as swap files, so that you don't
" loose undo history when quitting and re-editing the same file.
if has("persistent_undo")
  set undodir=$VIMHOME/undo
  set undofile
  set undoreload=10000
  if !isdirectory(&undodir) && exists("*mkdir")
    call mkdir(&undodir, "p", 0700)
  endif
endif
" }}}

" Misc Options {{{

set mouse=a         " enable mousing around
set nocompatible    " drop vi-compatability
set list            " mark tabs, trailing spaces, etc
set tabstop=4       " 4-space tabs
set expandtab       " expanded spaces rather than actual tabs
set shiftwidth=4    " 4-space indent/dedent
set cursorline      " mark the current cursor line...
set nocursorcolumn  " ...but not the column.
set scrolloff=3     " Try to keep 3 lines after cursor
set sidescrolloff=3 " Try to keep 3 columns after cursor
set splitbelow      " horizontal splits below rather than above
set splitright      " vertical splits right rather than left
set smartindent     " auto indent new lines
set noshowmode      " redundant with mode in airline
if has("&swapsync")
  set swapsync= " don't fsync swap files
endif

" TODO: if you want to change mapleader (deafults to "\", do it here):
" let mapleader=","

" }}}

" File Browsing {{{
let g:netrw_banner = 1
let g:netrw_liststyle = 3
let g:netrw_sizestyle = 'H'

nmap <leader>- <Plug>VinegarSplitUp
nmap <leader>\| <Plug>VinegarVerticalSplitUp

" }}}

" Searching {{{
set ignorecase " case insensitive matching...
set smartcase  " ...but only if the user didn't explicate case.
set hlsearch   " highlight matches
" NOTE: highligting doesn't have to be disabled to be temporarily hidden:
" - you can run `:nohlsearch` to turn it off until the next search
" - vim-sensible extends <Ctrl>-l so that it runs `:nohlsearch`
" - furthermore, the following automatically turns off highlighting when in
"   insert mode

augroup hlsearch
  autocmd InsertEnter * :setlocal nohlsearch " Disable hlsearch in insert mode...
  autocmd InsertLeave * :setlocal   hlsearch " ...enable it when we come out.
augroup END

" These bindings automatically prepend a `\v` to new searches so that they are
" in "very magic" mode. This upgrades the regex language to be closer to PCRE
" than POSIX (but still not quite a modern PCRE dialect!)
"
" See `:help /magic` for more.
nnoremap / /\v
nnoremap ? ?\v

" }}}

" Hack filetype for some extensions {{{
augroup filetype_ext_hacks
  " Since I frequently edit Markdown files, and never Modula files
  autocmd BufRead,BufNewFile *.md setlocal filetype=markdown
augroup END
" }}}

" Folding {{{

set foldmethod=indent " default to indent folding
set foldlevelstart=1  " with one level open

" }}}

" Terminal options {{{
if $TERM =~ 'xterm' || $TERM =~ 'screen'
  set ttyfast
endif
" }}}

" vimscript editing convenience {{{
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
inoremap <leader>ev <esc>:vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
" }}}

" easier re-sync for lazy diff algorithm
nnoremap du :diffupdate<cr>

" vim:set foldmethod=marker foldlevel=0 ts=2 sw=2 expandtab:
