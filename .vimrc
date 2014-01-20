call pathogen#infect()
call pathogen#helptags()

set noshiftround

if !empty($POWERLINE_BINDINGS)
    set runtimepath+=$POWERLINE_BINDINGS/vim
    set noshowmode " don't show mode below statusline (redundant with powerline)
endif

" Options {{{

syntax on
filetype plugin indent on

set nocompatible " This is an "option" apparently...

set scrolloff=3 " Try to keep 3 lines after cursor
set cursorline

set virtualedit=all
set smartindent
set foldmethod=indent
set swapsync=

set expandtab
set tabstop=4
set shiftwidth=4

set nospell
set splitbelow
set splitright

"set formatoptions=croq2lj

set list

" completion
set wildmode=longest,list:longest
set undolevels=1000

" searching {{{
set ignorecase " Do case insensitive matching...
set smartcase  " ...but only if the user didn't explicitly case
set hlsearch   " highlight while searching

augroup hlsearch
autocmd InsertEnter * :setlocal nohlsearch
autocmd InsertLeave * :setlocal   hlsearch
augroup END
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
nnoremap <leader><C-p> :set invpaste<cr>
set pastetoggle=<leader><C-p>
" }}}

" GUI options {{{
if has("gui_running")
  "set guifont=Inconsolata\ for\ Powerline:h13
  "set guifont=Anonymous\ Pro\ for\ Powerline:h13
  set guifont=Source\ Code\ Pro\ Light\ for\ Powerline:h12
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

" autocompile some files {{{
function! LessMake()
  let current_file = shellescape(expand('%:p'))
  let filename = shellescape(expand('%:r'))
  execute "!lessc " . current_file . " " . filename . ".css"
endfunction
augroup autocompile
autocmd BufWritePost *.coffee CoffeeMake
autocmd BufWritePost *.less call LessMake()
augroup END
" }}}

augroup git
autocmd Filetype gitcommit setlocal spell textwidth=72
augroup END

" Mappings {{{

" exiting insert mode by ctrl-cr
inoremap <C-CR> <Esc>

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
nnoremap <leader>go yaw:Gsplit <C-r>"<cr>
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
nnoremap <leader>ic :set ignorecase!<cr>
" }}}

nnoremap <leader>gf :set guifont=*<cr>

" }}}

" Lisp settings {{{
if isdirectory(expand("$HOME/HyperSpec/Body"))
    let g:slimv_clhs_root=expand("file://$HOME/HyperSpec/Body/")
endif
let g:lisp_rainbow = 1
" }}}

" Markdown {{{
augroup markdown
autocmd BufRead,BufNewFile *.md setlocal filetype=markdown foldmethod=syntax
augroup END
" }}}

nnoremap <leader>tt :Tab<cr>
nnoremap <leader>t= :Tab/=/<cr>
nnoremap <leader>t, :Tab/,/<cr>
nnoremap <leader>t: :Tab/:/<cr>

" vim:set foldmethod=marker foldlevel=0 ts=2 sw=2 expandtab:
