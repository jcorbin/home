call pathogen#infect()

syntax on

filetype plugin indent on

" Really, who cares about Vi compat anymore...
set nocompatible

let mapleader=","

set showcmd     " Show (partial) command in status line.
set showmatch   " Show matching brackets.
set mouse=a     " Enable mouse usage (all modes) in terminals
set scrolloff=3 " Try to keep 3 lines after cursor
set ruler
set nospell

" searching
nnoremap <leader><space> :nohlsearch<cr>
set ignorecase " Do case insensitive matching
set smartcase  " Do smart case matching
set incsearch  " Incremental search
set hlsearch   " highlight while searching

" persistent undo data
set undodir=~/.vim/undo
set undofile
set undolevels=1000
set undoreload=10000

" Paste Toggling with <F12>
map <F12> setenvpastemap
set pastetoggle=<F12>

" Show tabs, trailing spaces, and line wraps
set list listchars=tab:^-,trail:_,extends:+,nbsp:.
set background=dark

" completion
set wildmode=longest,list:longest

if has("gui_running")
	set cursorline " highlight the cursor's line
	set guifont=Inconsolata\ Medium\ 9,Droid\ Sans\ Mono\ 9,DejaVu\ Sans\ Mono\ 9,Bitstream\ Vera\ Sans\ Mono\ 9
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
endif

if $TERM =~ 'xterm' || $TERM =~ 'screen'
	set ttyfast
endif

set virtualedit=all

set expandtab
set tabstop=4
set shiftwidth=4

set foldmethod=indent
set swapsync=
set modeline
set laststatus=2

nnoremap <F5> :GundoToggle<CR>

" Vim 7.3 introduced relativenumber
if version >= 703
  set relativenumber
else
  set number
endif

" C-t for new tab
map <C-T> <Esc>:tabnew<CR>

" Determine colorscheme
if has("gui_running")
	colorscheme moria
elseif $TERM =~ '256'
	colorscheme inkpot
else
	colorscheme desert
endif

let xml_use_xhtml=1
let g:tex_flavor='latex'

let perl_include_pod = 1
let perl_want_scope_in_variables = 1
let perl_extended_vars = 1

" vim:set ts=2 sw=2 noexpandtab:
