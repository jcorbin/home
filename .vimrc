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
set cursorline

" searching
nnoremap <leader><space> :nohlsearch<cr>
set ignorecase " Do case insensitive matching
set smartcase  " Do smart case matching
set incsearch  " Incremental search
set hlsearch   " highlight while searching
nohlsearch
set formatoptions=croq2lj

nnoremap du :diffupdate<cr>

" fugitive bindings
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>g: :Git 
nnoremap <leader>g! :Gsplit! 
nnoremap <leader>gD :Gsplit! diff<cr>
nnoremap <leader>ga :Git add %<cr>
nnoremap <leader>gp :Git add --patch %<cr>
nnoremap <leader>gr :Git reset %<cr>

set undolevels=1000
" Persistent undo (vim 7.3+)
if has("persistent_undo")
	set undodir=~/.vim/undo
	set undofile
	set undoreload=10000
	if !isdirectory(&undodir) && exists("*mkdir")
		call mkdir(&undodir, "p", 0700)
	endif
endif

" save swap files in one place
set directory=$HOME/.vim/swap/$HOSTNAME//
if exists("*mkdir") && !isdirectory($HOME . "/.vim/swap/" . $HOSTNAME)
	call mkdir($HOME . "/.vim/swap/" . $HOSTNAME, "p", 0700)
endif

" Paste Toggling with <F12>
map <F12> setenvpastemap
set pastetoggle=<F12>

" Show tabs, trailing spaces, and line wraps
set list listchars=tab:^-,trail:_,extends:+,nbsp:.
set background=dark

" completion
set wildmode=longest,list:longest

if has("gui_running")
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

set autoindent
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
"
" NOTE: jellybeans also great choice, toss up for gui in lieu of moria and 256
"       term in lieu of xoria; it's similar, but more subdued, at the cost of
"       contrast in a few points.
if has("gui_running")
	colorscheme moria
elseif $TERM =~ '256'
	colorscheme xoria256
else
	colorscheme desert
endif

" autocompile coffee script files on write
au BufWritePost *.coffee silent CoffeeMake!

let xml_use_xhtml=1
let g:tex_flavor='latex'

let perl_include_pod = 1
let perl_want_scope_in_variables = 1
let perl_extended_vars = 1

" vim:set ts=2 sw=2 noexpandtab:
