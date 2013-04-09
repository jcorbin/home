call pathogen#infect()

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
set background=dark

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
if exists("*mkdir") && !isdirectory($HOME . "/.vim/swap")
  call mkdir($HOME . "/.vim/swap", "p", 0700)
endif
" }}}

"}}}

" Paste Toggling with <F12> {{{
map <F12> setenvpastemap
set pastetoggle=<F12>
" }}}

" GUI options {{{
if has("gui_running")
  set guifont=Inconsolata:h12
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
  LuciusBlack

" }}}
" Terminal options {{{
else
  if $TERM =~ 'xterm' || $TERM =~ 'screen'
    set ttyfast
  endif

  " togglable mouse usage {{{
  function! ToggleMouse()
    if &mouse == ""
      set mouse=a
    else
      set mouse=
    endif
  endfunction
  nnoremap <leader>m :call ToggleMouse()<cr>
  set mouse=a " Enable mouse usage (all modes) in terminals
  " }}}

  set background=dark
  " Determine colorscheme
  if &t_Co == 256
    colorscheme xoria256
  else
    colorscheme desert
  endif

endif
" }}}

" line numbering {{{
function! ToggleNumbering()
  if &number == 1
    set nonumber
    let s:lastnumber = "number"
  elseif &relativenumber == 1
    set norelativenumber
    let s:lastnumber = "relativenumber"
  elseif s:lastnumber == "number"
    set number
  else
    set relativenumber
  endif
endfunction
nnoremap <leader># :call ToggleNumbering()<cr>
if version >= 703
  set relativenumber
else
  set number
endif
" }}}

" autocompile coffee script files on write
au BufWritePost *.coffee silent CoffeeMake!

" Mappings {{{

" exiting insert mode {{{

" enter exits insert mode, but can toggle back to normaly with shift-enter
function! ToggleEnterMapping()
  if empty(mapcheck('<CR>', 'i'))
    inoremap <CR> <Esc>`^
    inoremap <Esc> <nop>
    return "\<Esc>"
  else
    iunmap <CR>
    iunmap <Esc>
    return "\<CR>"
  endif
endfunction

inoremap <CR> <Esc>
inoremap <Esc> <nop>
inoremap <expr> <S-CR> ToggleEnterMapping()
inoremap <c-c> <nop>
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

nnoremap <F5> :GundoToggle<CR>
nnoremap du :diffupdate<cr>

" vimrc editing convenience {{{
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
inoremap <leader>ev <esc>:vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
" }}}

" disable search highlighting until next search
nnoremap <leader><space> :nohlsearch<cr>
" }}}

" vim:set foldmethod=marker foldlevel=0 ts=2 sw=2 expandtab:
