" plugins {{{
" https://github.com/junegunn/vim-plug
call plug#begin('~/.config/nvim/plugged')

Plug 'Shougo/deoplete.nvim'
Plug 'Shougo/echodoc.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'Shougo/neosnippet.vim'
Plug 'bling/vim-airline'
Plug 'bling/vim-bufferline'
Plug 'edkolev/promptline.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'elzr/vim-json'
Plug 'fatih/vim-go'
Plug 'godlygeek/tabular'
Plug 'honza/vim-snippets'
Plug 'jcorbin/vim-bindsplit'
Plug 'jcorbin/vim-fold-toggle'
Plug 'jcorbin/vim-number-cycle'
Plug 'junegunn/goyo.vim'
Plug 'kien/ctrlp.vim'
Plug 'majutsushi/tagbar'
Plug 'marijnh/tern_for_vim'
Plug 'mhinz/vim-grepper'
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
Plug 'vim-utils/vim-man'

call plug#end()
" }}}

" colorscheme {{{

set background=dark

let g:rehash256 = 1 " better 256-terminal colors for molokai
let g:molokai_original = 0
colorscheme molokai

" }}}

" *line {{{

" airline {{{
let g:airline_powerline_fonts=0
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#eclim#enabled = 1
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#capslock#enabled = 1
" }}}

" bufferline {{{
" let g:airline#extensions#bufferline#enabled = 0
let g:airline#extensions#bufferline#enabled = 1
let g:bufferline_echo = 0

let g:bufferline_active_buffer_left = '*'
let g:bufferline_active_buffer_right = ''
" }}}

" tmuxline {{{
let g:airline#extensions#tmuxline#enabled = 0
let g:tmuxline_powerline_separators = 0
" }}}

" promptline {{{

let g:promptline_powerline_symbols = 0

" sections (a, b, c, x, y, z, warn) are optional
let g:promptline_preset = {
            \'a' : [ promptline#slices#vcs_branch() ],
            \'b' : [ promptline#slices#cwd() ],
            \'c' : [ promptline#slices#git_status() ],
            \'warn' : [ promptline#slices#last_exit_code() ],
            \'z' : [ promptline#slices#jobs() ],
            \'options': {
            \  'left_sections' : [ 'b', 'a', 'c' ],
            \  'right_sections' : [ 'warn', 'z' ],
            \  'left_only_sections' : [ 'b', 'a', 'c', 'warn' ]
            \}}

let g:promptline_symbols = {
            \ 'left'           : '',
            \ 'right'          : '',
            \ 'left_alt'       : '',
            \ 'right_alt'      : '',
            \ 'dir_sep'        : '/',
            \ 'truncation'     : '…',
            \ 'vcs_branch'     : '',
            \ 'battery'        : '',
            \ 'space'          : ' '}

let g:airline#extensions#promptline#enabled = 1
let g:airline#extensions#promptline#snapshot_file = "~/.promptline.sh"
" }}}

" }}}

" Options {{{

set cursorline
set cursorcolumn
set expandtab
set list
set scrolloff=3 " Try to keep 3 lines after cursor
set splitbelow
set splitright
set virtualedit=all

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
  set undodir=$HOME/.config/nvim/undo
  if !isdirectory(&undodir) && exists("*mkdir")
    call mkdir(&undodir, "p", 0700)
  endif
endif
" }}}

" Save swap files in central location {{{
set swapsync=
set directory=$HOME/.config/nvim/swap
if exists("*mkdir") && !isdirectory(&directory)
  call mkdir(&directory, "p", 0700)
endif
" }}}

" Spelling {{{
set spell

" ... except for some filetypes
augroup nospell
  autocmd FileType help setlocal nospell
  autocmd FileType man setlocal nospell
  autocmd FileType startify setlocal nospell
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

" set foldmethod=syntax
" let javaScript_fold=1         " JavaScript
" let perl_fold=1               " Perl
" let php_folding=1             " PHP
" let r_syntax_folding=1        " R
" let ruby_fold=1               " Ruby
" let sh_fold_enabled=1         " sh
" let vimsyn_folding='af'       " Vim script
" let xml_syntax_folding=1      " XML

" syntax folding for some filetypes
augroup syntax_folding
  autocmd FileType markdown setlocal foldmethod=syntax
  autocmd FileType json setlocal foldmethod=syntax
  autocmd FileType javascript setlocal foldmethod=syntax
augroup END

" foldcolumn on by default...
" set foldcolumn=4
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

" Go! {{{
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>f <Plug>(go-info)
au FileType go nmap <leader>o <Plug>(go-doc)
au FileType go nmap <leader>d <Plug>(go-def)
au FileType go nmap <leader>i :GoImports<Cr>
let g:go_auto_type_info = 1
let g:go_jump_to_error = 1
let g:go_fmt_command = "goimports"
" let g:go_fmt_options = ''
" let g:go_fmt_fail_silently = 0
let g:go_highlight_operators = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_build_constraints = 1

augroup nolistgo
  autocmd FileType go setlocal nolist
augroup END

" }}}

" deoplete {{{
let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 1

inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()

" echodoc
set noshowmode
let g:echodoc_enable_at_startup=1

" }}}

" neosnippet {{{
imap <C-e>     <Plug>(neosnippet_expand_or_jump)
smap <C-e>     <Plug>(neosnippet_expand_or_jump)
xmap <C-e>     <Plug>(neosnippet_expand_target)
imap <C-f>     <Plug>(neosnippet_jump)
smap <C-f>     <Plug>(neosnippet_jump)
" }}}

" Java ... {{{
let g:EclimCompletionMethod = 'omnifunc'
au FileType java nmap <leader>i :JavaImport<Cr>
" }}}

" Mappings {{{

let mapleader=","

" bindsplit
nmap <leader>bs <Plug>BindsplitVsplit

" no arrow keys for history
cnoremap <C-n> <down>
cnoremap <C-p> <up>

" grepper {{{

nmap gs  <plug>(GrepperOperator)
xmap gs  <plug>(GrepperOperator)

let g:grepper           = {}
let g:grepper.tools     = ['git', 'pt', 'grep']
let g:grepper.open      = 1
let g:grepper.switch    = 1
let g:grepper.jump      = 0
let g:grepper.next_tool = '<leader>g'

" }}}

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
