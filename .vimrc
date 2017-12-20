" plugins {{{

" Define $VIMHOME:
" - for NeoVim it's the directory that contains $MYVIMRC, usually
"   ~/.config/nvim on unix
" - for Vim it's ~/.vim on unix
" - TODO: add support for Windows if you need it
let $VIMHOME=expand('<sfile>:p:h')
if $VIMHOME == $HOME
  let $VIMHOME=$HOME.'/.vim'
endif

" setup vim-plug, downloading it if needed
" see https://github.com/junegunn/vim-plug
if empty(glob($VIMHOME.'/autoload/plug.vim'))
    if !isdirectory($VIMHOME.'/autoload')
      call mkdir($VIMHOME.'/autoload', "p")
    endif
    !curl -fLo $VIMHOME/autoload/plug.vim --create-dirs
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

" Command to (un)comment things
Plug 'tpope/vim-commentary'

" Better statusline
Plug 'bling/vim-airline'

" colorschemes
Plug 'pR0Ps/molokai-dark'
Plug 'robertmeta/nofrils'

" better support for certain languages
Plug 'sheerun/vim-polyglot'
Plug 'fatih/vim-go'
let g:polyglot_disabled = ['go', 'markdown']

" for snippets
Plug 'Shougo/neosnippet-snippets'
Plug 'Shougo/neosnippet.vim'
Plug 'honza/vim-snippets'

Plug 'Shougo/denite.nvim'

" useful starting screen (load MRU file, fortune, etc)
Plug 'mhinz/vim-startify'

" git integration
Plug 'tpope/vim-fugitive'

" line things up
Plug 'godlygeek/tabular'

" grep integration (for any grep-like program)
Plug 'mhinz/vim-grepper'

" mostly for casing coercion (aka "bikeshed transit" ;-))
Plug 'tpope/vim-abolish'

" autodetect indent level (stop running `:set ts=X sw=X` all the time when
" crossing tribe lines)
Plug 'tpope/vim-sleuth'

" grab bag, mostly for the "paired" bindings
Plug 'tpope/vim-unimpaired'

" allows Ctrl-A/X to inc/dec dates (and more!)
Plug 'tpope/vim-speeddating'

" live linting, no more waiting for write!
Plug 'w0rp/ale'

if has("nvim")
  " TODO: re-consider https://github.com/tjdevries/nvim-langserver-shim, since
  " it looks to be trying for upstream
  Plug 'autozimu/LanguageClient-neovim', { 'do': ':UpdateRemotePlugins' }

  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'zchee/deoplete-go'
  Plug 'Shougo/echodoc.vim'
else
  Plug 'Shougo/neocomplete.vim'
endif

call plug#end()
" }}}

" Save swap files in one place... {{{
if !has("nvim")
  " ...instead of beside the file being edited. This ends up being kinder to
  " things like SCM and remote file systems.
  " Neovim already does similar outof the box (under ~/.local/share/nvim/swap/...).
  set directory=$VIMHOME/swap
  if !isdirectory(&directory)
    call mkdir(&directory, "p", 0700)
  endif
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

set virtualedit=all " edit beyond EOL
set nowrap
set fillchars=
set lazyredraw
set shortmess=atToO
set cmdheight=1

if has("nvim")
  set inccommand=nosplit
endif

" }}}

" Language Server Clients {{{

let g:LanguageClient_serverCommands = {
    \ 'go': [$GOPATH.'/bin/go-langserver', '-pprof', ':26060'],
    \ }

" Automatically start language servers.
let g:LanguageClient_autoStart = 1

" }}}

" File Browsing {{{
let g:netrw_banner = 1
let g:netrw_liststyle = 3
let g:netrw_sizestyle = 'H'

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
" nnoremap / /\v
" nnoremap ? ?\v

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
autocmd Syntax c,cpp,vim,xml,html,xhtml,go setlocal foldmethod=syntax

" set foldmethod=syntax
" let javaScript_fold=1         " JavaScript
" let perl_fold=1               " Perl
" let php_folding=1             " PHP
" let r_syntax_folding=1        " R
" let ruby_fold=1               " Ruby
" let sh_fold_enabled=1         " sh
" let vimsyn_folding='af'       " Vim script
" let xml_syntax_folding=1      " XML

" syntax folding for some filetypes {{{
augroup syntax_folding
  autocmd FileType markdown setlocal foldmethod=syntax
  autocmd FileType json setlocal foldmethod=syntax
  autocmd FileType javascript setlocal foldmethod=syntax
augroup END
" }}}

" Terminal options {{{
if $TERM =~ 'xterm' || $TERM =~ 'screen'
  set ttyfast
endif
" }}}

" airline {{{

" let g:airline#extensions#whitespace#enabled = 1
" let g:airline#extensions#capslock#enabled = 1

let g:airline#extensions#wordcount#enabled = 0
let g:airline#extensions#branch#enabled = 0

let g:airline_detect_spell = 0
let g:airline_detect_spelllang = 0
let g:airline_exclude_preview = 1
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

" or copy paste the following into your vimrc for shortform text
let g:airline_mode_map = {
    \ '__' : '-',
    \ 'n'  : 'N',
    \ 'i'  : 'I',
    \ 'R'  : 'R',
    \ 'c'  : 'C',
    \ 'v'  : 'V',
    \ 'V'  : 'V',
    \ '' : 'V',
    \ 's'  : 'S',
    \ 'S'  : 'S',
    \ '' : 'S',
    \ }

" }}}

" Ale {{{

let g:ale_sign_error='⊘'
let g:ale_sign_warning='⚠'

" }}}

" Go! {{{

" " vim-go {{{

let g:go_doc_keywordprg_enabled = 0
let g:go_echo_go_info = 1

let g:go_fmt_command = "goimports"
let g:go_fmt_fail_silently = 1
let g:go_fmt_autosave = 1

let g:go_auto_type_info = 0
let g:go_jump_to_error = 1

let g:go_highlight_build_constraints = 1
let g:go_highlight_functions = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_fields = 1
let g:go_highlight_structs = 1
let g:go_highlight_generate_tags = 1

let g:go_snippet_engine = "neosnippet"
let g:go_template_autocreate = 0

let g:go_metalinter_autosave = 0 " XXX disabeld due to failing on fugitive buffers
" let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
" let g:go_metalinter_autosave_enabled = ['vet', 'golint']
" let g:go_metalinter_deadline = "5s"

let g:go_term_mode = "split"
let g:go_term_enabled = 1

" }}}

augroup nolistgo
  autocmd FileType go setlocal nolist
augroup END

" }}}

" deoplete {{{
if has("nvim")
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#disable_auto_complete = 1
  set completeopt=menu,preview,longest,noselect
  set infercase

  " echodoc
  let g:echodoc_enable_at_startup=1

endif
" }}}

" neosnippet {{{
imap <C-e>     <Plug>(neosnippet_expand_or_jump)
smap <C-e>     <Plug>(neosnippet_expand_or_jump)
xmap <C-e>     <Plug>(neosnippet_expand_target)
imap <C-f>     <Plug>(neosnippet_jump)
smap <C-f>     <Plug>(neosnippet_jump)

" TODO get plugged root programatically for g:neosnippet#snippets_directory
let g:neosnippet#snippets_directory="$HOME/.config/nvim/snippets,$HOME/.config/nvim/plugged/vim-snippets/snippets"

" For conceal markers.
set conceallevel=1
set concealcursor=niv

" }}}

" Tab key {{{

" Invokes deoplete in insert mode.
imap <silent> <expr><Tab> deoplete#mappings#manual_complete()

" Try to expand or jump in normal mode.
snoremap <expr><Tab>
\ neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" :
\ "\<Tab>"

" }}}

" CScope {{{

if has("cscope")
  set csprg=/usr/local/bin/cscope
  set csto=0
  set cst
  set nocsverb
  " add any database in current directory
  if filereadable("cscope.out")
      cs add cscope.out
  " else add database pointed to by environment
  elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
  endif
  set csverb
endif


" }}}

" Mappings {{{

let mapleader="\\"

" easier use of ranged global normal {{{
" uses, and organizes around, the undocumented `g\/` and `g\&` forms describe
" in ex_global:

nmap <leader>s :Startify<cr>

" File Browsing
nmap <leader>- <Plug>VinegarSplitUp
nmap <leader>\| <Plug>VinegarVerticalSplitUp

" Perform a normal command...
" ...on every line of the buffer
nnoremap <leader>n :%normal<space>
" ...on every line of a visual selection
vnoremap <leader>n :normal<space>
" ...on every line of the last visual selection.
nnoremap <leader>vn :'<,'>normal<space>

" Same progression filtered by the last search pattern.
nnoremap <leader>/: :%g\/<space>
nnoremap <leader>/n :%g\/normal<space>
vnoremap <leader>/n :g\/normal<space>
nnoremap <leader>/v: :'<,'>g\/<space>
nnoremap <leader>/vn :'<,'>g\/normal<space>

" Same progression filtered by the last substitution pattern.
nnoremap <leader>&: :%g\&<space>
nnoremap <leader>&n :%g\&normal<space>
vnoremap <leader>&n :g\&normal<space>
nnoremap <leader>&v: :'<,'>g\&<space>
nnoremap <leader>&vn :'<,'>g\&normal<space>

" }}}

" no arrow keys for history
cnoremap <C-n> <down>
cnoremap <C-p> <up>

" grepper {{{

nmap gs  <plug>(GrepperOperator)
xmap gs  <plug>(GrepperOperator)

nnoremap <leader>Gg :Grepper -tool git<cr>
nnoremap <leader>Gp :Grepper -tool pt<cr>

let g:grepper           = {}
let g:grepper.tools     = ['git', 'pt', 'grep', 'ack']
let g:grepper.open      = 1
let g:grepper.switch    = 1
let g:grepper.jump      = 0
let g:grepper.next_tool = '<leader>g'
let g:grepper.pt = {
  \ 'pt':        { 'grepprg':    'pt --nogroup --skip-vcs-ignores',
  \                'grepformat': '%f:%l:%m' }}

" }}}

" vimscript editing convenience {{{
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
inoremap <leader>ev <esc>:vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
" }}}

" easier re-sync for lazy diff algorithm
nnoremap du :diffupdate<cr>

" fugitive bindings {{{
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>g: :Git<space>
nnoremap <leader>go yaw:Gsplit <C-r>"<cr>

" }}}

" go bindings {{{

au FileType go nmap <leader>gol <Plug>(go-metalinter)
au FileType go nmap <leader>gor <Plug>(go-run)
au FileType go nmap <leader>got <Plug>(go-test)
au FileType go nmap <Leader>god <Plug>(go-doc)

" au FileType go nmap <leader>b <Plug>(go-build)
" au FileType go nmap <leader>c <Plug>(go-coverage)
" au FileType go nmap <Leader>e <Plug>(go-rename)
" au FileType go nmap <Leader>s <Plug>(go-implements)
" au FileType go nmap <Leader>i <Plug>(go-info)
" au FileType go nmap <Leader>dd <Plug>(go-def)
" au FileType go nmap <Leader>ds <Plug>(go-def-split)
" au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
" au FileType go nmap <Leader>dt <Plug>(go-def-tab)
" au FileType go nmap <leader>f <Plug>(go-info)
" au FileType go nmap <leader>d <Plug>(go-def)
" au FileType go nmap <leader>i :GoImports<Cr>

" }}}

" Stacked Diff Helpers {{{
" - the bf binding finds any decorated picks, and follows them with an `exec
"   git branch -f name`
" - the gbf binding then anchors on those added execs allowing you to layer
"   further edits on each instance
au FileType gitrebase nmap <leader>bf :g/\v^pick.*\)$/norm $byeoexec git branch -f <C-v><C-r>"<Return>
au FileType gitrebase nmap <leader>gbf :g/^exec git branch -f/norm<Space>
" }}}

" Tabular
nnoremap <leader>tt :Tab<cr>
nnoremap <leader>t\| :Tab/\|/<cr>
nnoremap <leader>t/ :Tab/\//<cr>
nnoremap <leader>t= :Tab/=/<cr>
nnoremap <leader>t, :Tab/,/<cr>
nnoremap <leader>t: :Tab/:/<cr>

" Denite basics
nmap <leader>b :Denite buffer<cr>
nmap <leader>d :Denite directory_rec<cr>
nmap <leader>f :Denite file_rec<cr>
nmap <leader>h :Denite help<cr>
nmap <leader>r :Denite register<cr>
nmap <leader>c :Denite colorscheme<cr>
" nmap <leader>l :Denite line<cr>

" Language Server Client
nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> gr  :call LanguageClient_textDocument_rename()<CR>
nmap <leader>ld :Denite documentSymbol<cr>
nmap <leader>lw :Denite workspaceSymbol<cr>
nmap <leader>lr :Denite references<cr>

" }}}

" Spelling {{{
set spell

" ... except for some filetypes
augroup nospell
  autocmd FileType help setlocal nospell
  autocmd FileType man setlocal nospell
  autocmd FileType startify setlocal nospell
  autocmd FileType gedoc setlocal nospell
  autocmd FileType godoc setlocal nospell
  autocmd FileType qf setlocal nospell
  autocmd FileType netrw setlocal nospell
  autocmd FileType vim-plug setlocal nospell
  autocmd FileType fugitiveblame setlocal nospell
  autocmd FileType goterm setlocal nospell
augroup END

" spell check in git mode
augroup git
autocmd Filetype gitcommit setlocal spell textwidth=72
augroup END

" }}}

" abbreviations {{{
augroup filetype_abbrs
  autocmd FileType javascript :iabbrev <buffer> vst var self = this;
augroup END
" }}}

" JSON {{{
let g:vim_json_syntax_conceal = 0
" }}}

" Startify {{{
let g:startify_change_to_dir = 0
" }}}

" colorscheme {{{

if has("&termguicolors")
  set termguicolors
endif

set background=dark

let g:nofrils_strbackgrounds=1

let g:hot_colors_name = 'molokai-dark'
let g:cool_colors_name = 'nofrils-dark'

try
    if g:colors_name == "default"
        execute 'colorscheme ' . g:hot_colors_name
    endif
catch E121
    execute 'colorscheme ' . g:hot_colors_name
endtry

function! ToggleHotCold()
  if g:colors_name == g:hot_colors_name
      execute 'colorscheme ' . g:cool_colors_name
  else
      execute 'colorscheme ' . g:hot_colors_name
  endif
endfunction

nnoremap cof :call ToggleHotCold()<CR>

" }}}

" vim:set foldmethod=marker foldlevel=0 ts=2 sw=2 expandtab:
