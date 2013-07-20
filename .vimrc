call pathogen#infect()

set laststatus=2 " always show the statusline

" Options {{{

syntax on
filetype plugin indent on

set nocompatible " This is an "option" apparently...

set showcmd     " Show (partial) command in status line.
set showmatch   " Show matching brackets.
set scrolloff=3 " Try to keep 3 lines after cursor
set ruler       " display line/col/percentage on right part of statusline
set cursorline

set virtualedit=all
set autoindent
set smartindent
set smarttab
set foldmethod=indent
set swapsync=

set expandtab
set tabstop=4
set shiftwidth=4

set nospell
set splitbelow
set splitright

"set formatoptions=croq2lj

" Show tabs, trailing spaces, and line wraps
set list listchars=tab:^-,trail:_,extends:+,nbsp:.

" completion
set wildmode=longest,list:longest
set undolevels=1000

" searching {{{
set ignorecase " Do case insensitive matching...
set smartcase  " ...but only if the user didn't explicitly case
set incsearch  " Incremental search
set hlsearch   " highlight while searching
nohlsearch
"}}}

let xml_use_xhtml=1
let g:tex_flavor='latex'

" Persistent undo (vim 7.3+) {{{
if has("persistent_undo")
  set undodir=~/.vim/undo
  set undofile
  set undoreload=10000
  if !isdirectory(&undodir) && exists("*mkdir")
    call mkdir(&undodir, "p", 0700)
  endif
endif
" }}}

" Save swap files in one place {{{
set directory=$HOME/.vim/swap
if exists("*mkdir") && !isdirectory(&directory)
  call mkdir(&directory, "p", 0700)
endif
" }}}

"}}}

" Paste Toggling with <F12> {{{
map <F12> setenvpastemap
set pastetoggle=<F12>
" }}}

" GUI options {{{
if has("gui_running")
  set guifont=Inconsolata:h13
  " guioptions:
  "   a - autoselect
  "   c - console dialogs
  "   e - gui tabline
  "   i - icon hint
  "   m - menubar
  "   g - grey out menu items
  "   r - right scroll always
  set guioptions=acgit
  set guiheadroom=0
  colorscheme lucius

" }}}
" Terminal options {{{
else
  if $TERM =~ 'xterm' || $TERM =~ 'screen'
    set ttyfast
  endif

  " Determine colorscheme
  if &t_Co == 256
    colorscheme lucius
    let g:lucius_no_term_bg=1
    LuciusBlack
  else
    set background=dark
    colorscheme desert
  endif

endif
" }}}

" autocompile coffee script files on write
au BufWritePost *.coffee CoffeeMake

" Mappings {{{

" exiting insert mode {{{

" disable escape for retraining
inoremap <Esc> <nop>

" enter exits insert mode, shift-enter to insert a newline
inoremap <CR> <Esc>
inoremap <S-CR> <CR>

" }}}

let mapleader=","

" fugitive bindings {{{
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>g: :Git
nnoremap <leader>g! :Gsplit!
nnoremap <leader>g\| :Gvsplit!
nnoremap <leader>gD :Gsplit! diff<cr>
nnoremap <leader>ga :Git add %<cr>
nnoremap <leader>gp :Git add --patch %<cr>
nnoremap <leader>gr :Git reset %<cr>
" }}}

nnoremap <leader>u :GundoToggle<CR>
nnoremap du :diffupdate<cr>

" vimscript editing convenience {{{
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
inoremap <leader>ev <esc>:vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>s% :source %<cr>
" }}}

" searching {{{
nnoremap / /\v
nnoremap ? ?\v
nnoremap <leader><space> :nohlsearch<cr>
nnoremap <leader>ic :set ignorecase!<cr>
" }}}

nnoremap <leader>gf :set guifont=*<cr>

" }}}

" vim:set foldmethod=marker foldlevel=0 ts=2 sw=2 expandtab:
