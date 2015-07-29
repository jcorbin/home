" plugins {{{
" https://github.com/junegunn/vim-plug
call plug#begin('~/.nvim/plugged')

Plug 'SirVer/ultisnips'
Plug 'elzr/vim-json'
Plug 'godlygeek/tabular'
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'jcorbin/vim-fold-toggle'
Plug 'jcorbin/vim-grep-operator'
Plug 'jcorbin/vim-lightline-integration'
Plug 'jcorbin/vim-number-cycle'
Plug 'junegunn/goyo.vim'
Plug 'kien/ctrlp.vim'
Plug 'majutsushi/tagbar'
Plug 'mhinz/vim-startify'
Plug 'pangloss/vim-javascript'
Plug 'scrooloose/syntastic'
Plug 'sjl/gundo.vim'
Plug 'solarnz/thrift.vim'
Plug 'tomasr/molokai'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-vinegar'
Plug 'marijnh/tern_for_vim'

call plug#end()
" }}}

let g:rehash256 = 1 " better 256-terminal colors for molokai
colorscheme molokai

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

" Line numbering {{{
set number
set relativenumber

" cycles between no, abs, and rel line numbering
nmap <leader># <Plug>NumberCycle
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

" mappings to make "very magic" the default
nnoremap / /\v
nnoremap ? ?\v
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

" Spelling {{{
set spell

" ... except for some filetypes
augroup nospell
  autocmd FileType help setlocal nospell
  autocmd FileType godoc setlocal nospell
  autocmd FileType qf setlocal nospell
  autocmd FileType netrw setlocal nospell
  autocmd FileType vim-plug setlocal nospell
  autocmd FileType fugitiveblame setlocal nospell
augroup END
" }}}

" Folding {{{

" default to indent folding
set foldmethod=indent
set foldlevelstart=1

" syntax folding for some filetypes
augroup syntax_folding
  autocmd FileType markdown setlocal foldmethod=syntax
  autocmd FileType json setlocal foldmethod=syntax
  autocmd FileType javascript setlocal foldmethod=syntax
augroup END

" foldcolumn on by default...
set foldcolumn=4
" ... except for
augroup NoFoldColumn
  autocmd Filetype help setlocal foldcolumn=0
  autocmd Filetype godoc setlocal foldcolumn=0
  autocmd Filetype gitcommit setlocal foldcolumn=0
  autocmd Filetype qf setlocal foldcolumn=0
  autocmd Filetype netrw setlocal foldcolumn=0
augroup END
" mapping to toggle it
nmap <leader>fc <Plug>FoldToggleColumn
" }}}

" hack filetype for some extensions {{{
augroup filetype_ext_hacks
  autocmd BufRead,BufNewFile *.md setlocal filetype=markdown
augroup END
" }}}

" Syntastic {{{
let g:syntastic_check_on_open = 1
let g:syntastic_aggregate_errors = 1
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_always_populate_loc_list = 1

" UltiSnips {{{
let g:UltiSnipsExpandTrigger="<c-e>"
let g:UltiSnipsJumpForwardTrigger="<c-e>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsEditSplit="vertical"
" }}}

" Mappings {{{

let mapleader=","

" vimscript editing convenience {{{
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
inoremap <leader>ev <esc>:vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>s% :source %<cr>
" }}}

" easier re-sync for lazy diff algorithm
nnoremap du :diffupdate<cr>

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

" TagBar
nnoremap <leader>tg :TagbarToggle<cr>

" Tabular
nnoremap <leader>tt :Tab<cr>
nnoremap <leader>t= :Tab/=/<cr>
nnoremap <leader>t, :Tab/,/<cr>
nnoremap <leader>t: :Tab/:/<cr>

" moar vinegar!
nmap _ <Plug>VinegarVerticalSplitUp

" GUndo
nnoremap <leader>gu :GundoToggle<CR>

" }}}

" abbreviations {{{
augroup filetype_abbrs
  autocmd FileType javascript :iabbrev <buffer> vst var self = this;
augroup END
" }}}

let g:vim_json_syntax_conceal = 0

" vim:set foldmethod=marker foldlevel=0 ts=2 sw=2 expandtab:
