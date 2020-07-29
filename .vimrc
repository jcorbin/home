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

" direnv integration
Plug 'direnv/direnv.vim'

" file browsing
Plug 'tpope/vim-eunuch'
Plug 'justinmk/vim-dirvish'
Plug 'kristijanhusak/vim-dirvish-git'

" Adds a new text object for "surrounding" things
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'

" Command to (un)comment things
Plug 'tpope/vim-commentary'

" Better statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" focus
Plug 'junegunn/goyo.vim'

" unicode
Plug 'chrisbra/unicode.vim'

" colorschemes
Plug 'pR0Ps/molokai-dark'      " high contrast
Plug 'jcorbin/darkula'         " medium contrast (darker version of IDEA's darcula)
Plug 'robertmeta/nofrils'      " the 'no color' colorscheme
Plug 'chriskempson/base16-vim' " framework of many 16-color themes
Plug 'cocopon/iceberg.vim'     " blue theme
Plug 'w0ng/vim-hybrid'         " lower contrast, tomorrow-esque scheme (feels like a muted molokai)

" Lobster!
Plug 'jcorbin/vim-lobster'

Plug 'jcorbin/neovim-termhide'

" Golang support
Plug 'fatih/vim-go'

" snippets
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'honza/vim-snippets'

" Plug 'hrsh7th/vim-vsnip'
" Plug 'hrsh7th/vim-vsnip-integ'
" " TODO watch https://github.com/archseer/snippets.nvim

" PlugInstall and PlugUpdate will clone fzf in ~/.fzf and run the install script
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" finder and dispatcher
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary' }

" useful starting screen (load MRU file, fortune, etc)
Plug 'mhinz/vim-startify'

" git integration
Plug 'tpope/vim-fugitive'

" line things up
Plug 'godlygeek/tabular'

" Undo history navigation
Plug 'mbbill/undotree'

" tags from lsp
Plug 'liuchengxu/vista.vim'

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

" LSP
Plug 'neovim/nvim-lsp'

Plug 'Shougo/neco-vim'
Plug 'Shougo/neco-syntax'
Plug 'Shougo/neoinclude.vim'

Plug 'haorenW1025/completion-nvim'
" XXX Plug 'haorenW1025/diagnostic-nvim'

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

set nojoinspaces

if has("nvim")
  set jumpoptions=stack
  set inccommand=nosplit
endif

" }}}

" LSP {{{

lua << EOF

require'nvim_lsp'.bashls.setup{}
require'nvim_lsp'.cssls.setup{}
require'nvim_lsp'.gopls.setup{}
require'nvim_lsp'.html.setup{}
require'nvim_lsp'.pyls.setup{}
require'nvim_lsp'.tsserver.setup{}
require'nvim_lsp'.vimls.setup{}

EOF

" autocmd Filetype vim setlocal omnifunc=v:lua.vim.lsp.omnifunc
" autocmd Filetype bash setlocal omnifunc=v:lua.vim.lsp.omnifunc

" " let g:lsp_semantic_enabled = 1
" let g:lsp_preview_float = 1

" let g:lsp_highlight_references_enabled = 1
" hi link lspReference MatchParen

nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>

nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>

nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

nnoremap <silent> <leader>f    <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <silent> <leader>a    <cmd>lua vim.lsp.buf.code_action()<CR>

" nnoremap <silent> <leader>l :LspDocumentDiagnostics<CR>
" nnoremap <silent> <leader>r :LspRename<CR>
" nnoremap <silent> <leader>e :LspNextError<CR>

" }}}

" File Browsing {{{

nmap <leader>- <Plug>(dirvish_split_up)
nmap <leader>\| <Plug>(dirvish_vsplit_up)

augroup dirvish_config
  autocmd!
  autocmd FileType dirvish nnoremap <buffer> % :e %
  autocmd FileType dirvish nnoremap <buffer> <leader>d :Mkdir %
augroup END

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
  autocmd!
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
  autocmd!
  " Since I frequently edit Markdown files, and never Modula files
  autocmd BufRead,BufNewFile *.md setlocal filetype=markdown
augroup END
" }}}

" Folding {{{

set foldmethod=indent " default to indent folding
set foldlevelstart=1  " with one level open

" syntax folding for some filetypes {{{
augroup syntax_folding
  autocmd!

  autocmd FileType go setlocal foldmethod=syntax
  autocmd FileType json setlocal foldmethod=syntax
  autocmd FileType javascript setlocal foldmethod=syntax

  " this kludge is the best we can do for markdown (due to inadequate syntax definition)
  autocmd FileType markdown setlocal foldmethod=expr foldexpr=MarkdownLevel()
augroup END

function! MarkdownLevel()
    let h = matchstr(getline(v:lnum), '^#\+')
    if empty(h)
        return "="
    else
        return ">" . len(h)
    endif
endfunction

" }}}

" }}}

" airline {{{

let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#vista#enabled = 1

" tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>< <Plug>AirlineSelectPrevTab
nmap <leader>> <Plug>AirlineSelectNextTab
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9

let g:airline#extensions#wordcount#enabled = 0
let g:airline#extensions#branch#enabled = 0

let g:airline_detect_spell = 0
let g:airline_detect_spelllang = 0
let g:airline_exclude_preview = 1

" }}}

" Go! {{{

" vim-go {{{

let g:go_fmt_autosave = 1

let g:go_def_mode = 'godef' " guru
let g:go_info_mode = 'gocode'
let g:go_fmt_command = "goimports"

if executable('gopls')
  let g:go_fmt_autosave = 1
  let g:go_info_mode = 'gopls'
  let g:go_def_mode = 'gopls'
  let g:go_fmt_command = 'gopls'
  let g:go_implements_mode = 'gopls'
  let g:go_imports_mode = 'gopls'

let g:go_gopls_use_placeholders = v:true
let g:go_gopls_complete_unimported = v:true
let g:go_gopls_deep_completion = v:true

let g:go_gopls_config={'fillreturns': v:true}

let g:go_gopls_analyses = {
  \ 'analyses': v:true,
  \ 'fillreturns': v:true,
  \ 'nonewvars': v:true,
  \ 'undeclaredname': v:true,
  \ 'unusedparams': v:true,
  \ }

endif

let g:go_doc_keywordprg_enabled = 0
let g:go_echo_go_info = 0

let g:go_fmt_fail_silently = 0

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

let g:go_term_mode = "split"
let g:go_term_enabled = 1

" }}}

" }}}

" Completion {{{

set completeopt=menu,longest
set infercase
set shortmess+=c

" Use completion-nvim in every buffer
autocmd BufEnter * lua require'completion'.on_attach()

" completion-nvim chained sources
let g:completion_auto_change_source = 1

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<Tab>" :
  \ completion#trigger_completion()
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
inoremap <c-c> <ESC>

" neovim 0.4.0+ : semi-transparent popup menu
if has('nvim') && has('termguicolors')
  silent! set pumblend=20
endif

" }}}

" snippets {{{

" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-e>     <Plug>(neosnippet_expand_or_jump)
smap <C-e>     <Plug>(neosnippet_expand_or_jump)
xmap <C-e>     <Plug>(neosnippet_expand_target)

" For conceal markers.
set conceallevel=1
set concealcursor=niv
augroup noconceal
  autocmd!
  autocmd FileType markdown setlocal conceallevel=0
augroup END

" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
let g:neosnippet#snippets_directory=$VIMHOME.'/plugged/vim-snippets/snippets'

" XXX vsnip " You can use other key to expand snippet.
" imap <expr> <C-j>   vsnip#available(1)  ? '<Plug>(vsnip-expand)'         : '<C-j>'
" imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
" smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
" imap <expr> <Tab>   vsnip#available(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
" smap <expr> <Tab>   vsnip#available(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
" imap <expr> <S-Tab> vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
" smap <expr> <S-Tab> vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" }}}

" Mappings {{{

let mapleader="\\"

" easier use of ranged global normal {{{
" uses, and organizes around, the undocumented `g\/` and `g\&` forms describe
" in ex_global:

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

let g:grepper           = {}
let g:grepper.dir       = 'repo,filecwd'
let g:grepper.tools     = ['git', 'pt', 'grep', 'ack']
let g:grepper.open      = 1
let g:grepper.switch    = 1
let g:grepper.jump      = 0
let g:grepper.next_tool = '<leader>g'
let g:grepper.pt = {
  \ 'pt':        { 'grepprg':    'pt --nogroup --skip-vcs-ignores',
  \                'grepformat': '%f:%l:%m' }}

" }}}

" vimrc {{{
nnoremap <leader>ve :vsplit $MYVIMRC<cr>
nnoremap <leader>vs :source $MYVIMRC<cr>
" }}}

" easier re-sync for lazy diff algorithm
nnoremap du :diffupdate<cr>

" fugitive bindings {{{
nnoremap <leader>G :G<space>
nnoremap <leader>ga :G add %<cr>
nnoremap <leader>gA :G add --update<cr>
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gC :Gcommit --amend<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gg :Ghud<cr>
nnoremap <leader>go yaw:Gsplit <C-r>"<cr>

nnoremap <leader>g> :G stash<cr>
nnoremap <leader>g< :G stash pop<cr>
nnoremap <leader>g! :G stash drop<cr>

" }}}

" go bindings {{{

au FileType go nmap <Leader>goa <Plug>(go-alternate-edit)
au FileType go nmap <Leader>goc <Plug>(go-coverage-toggle)
au FileType go nmap <Leader>god <Plug>(go-doc)
au FileType go nmap <Leader>gof <Plug>(go-test-func)
au FileType go nmap <Leader>goi <Plug>(go-imports)
au FileType go nmap <leader>gol <Plug>(go-metalinter)
au FileType go nmap <leader>gor <Plug>(go-run)
au FileType go nmap <leader>got <Plug>(go-test)

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

" Undotree
let g:undotree_ShortIndicators=1
nnoremap <leader>ut :UndotreeToggle<cr>

" Clap
let g:clap_disable_run_rooter = v:true
nnoremap <leader>cc :Clap<cr>
nnoremap <leader>cb :Clap buffers<cr>
nnoremap <leader>cf :Clap filer<cr>

" Vista
let g:vista_default_executive = 'vim_lsp'
nnoremap <leader>vv :Vista<cr>
nnoremap <leader>vf :Vista focus<cr>

" Tabular
nnoremap <leader>tt :Tab<cr>
nnoremap <leader>t\| :Tab/\|/<cr>
nnoremap <leader>t/ :Tab/\//<cr>
nnoremap <leader>t= :Tab/=/<cr>
nnoremap <leader>t, :Tab/,/<cr>
nnoremap <leader>t: :Tab/:/<cr>

" }}}

" Spelling {{{
set spell

" ... except for some filetypes
augroup nospell
  autocmd!
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
  autocmd FileType godebug* setlocal nospell
  autocmd FileType dirvish setlocal nospell
  if has("nvim")
    autocmd TermOpen * setlocal nospell
  endif
augroup END

" spell check in git mode
augroup git
  autocmd!
  autocmd Filetype gitcommit setlocal spell textwidth=72
augroup END

" }}}

" abbreviations {{{
augroup filetype_abbrs
  autocmd!
  autocmd FileType javascript :iabbrev <buffer> vst var self = this;
augroup END
" }}}

" JSON {{{
let g:vim_json_syntax_conceal = 0
" }}}

" colorscheme {{{

if has("termguicolors")
  set termguicolors
endif

set background=dark

let g:nofrils_strbackgrounds=1

let g:hot_colors_name = 'darkula'
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

nnoremap yof :call ToggleHotCold()<CR>

" }}}

" Toggle Statusline {{{

function! ToggleStatus()
  if &laststatus == 0
    set showmode
    set ruler
    set showcmd
    set laststatus=2
    AirlineToggle
  else
    AirlineToggle
    set laststatus=0
    set noshowmode
    set noruler
    set noshowcmd
  endif
endfunction

nnoremap yoS :call ToggleStatus()<CR>

" }}}

" Cursor {{{

" blinking, shape changing, and color changing (requires colorscheme support)
set guicursor
      \=a:block-blinkwait400-blinkoff200-blinkon200
      \,n:nCursor
      \,c:cCursor
      \,v:vCursor
      \,i-ci-ve:ver25-iCursor
      \,r-cr:hor25-rCursor
      \,o:hor50-nCursor

" }}}

" Focus {{{

nmap yogg :Goyo<cr>
nmap yog5 :Goyo 50%<cr>
nmap yog6 :Goyo 60%<cr>
nmap yog7 :Goyo 70%<cr>
nmap yog8 :Goyo 80%<cr>
nmap yog9 :Goyo 90%<cr>

let g:goyo_width='100%'
let g:goyo_height='100%'

" }}}

" Sessions {{{

nnoremap <leader>s :Startify<cr>

set sessionoptions=blank,buffers,curdir,folds,help,winsize

let g:startify_enable_special = 0
let g:startify_use_env = 1
let g:startify_fortune_use_unicode = 1

let g:startify_change_to_dir = 1
let g:startify_change_to_vcs_root = 1

let g:startify_bookmarks = [
\ {'hi': '$HOME/home-int'},
\ {'vi': '$VIMHOME'},
\ ]

let g:startify_session_autoload = 1

let g:startify_session_persistence = 1
let g:startify_session_savevars = [
\ 'g:startify_session_savevars',
\ 'g:startify_session_savecmds',
\ 'g:startify_lists',
\ 'g:startify_commands',
\ 'g:startify_custom_header',
\ ]

function! UnstartifySession()
  let g:startify_custom_header = 'startify#fortune#cowsay()'
  let g:startify_lists = [
  \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
  \ { 'type': 'files',     'header': ['   MRU']            },
  \ { 'type': 'sessions',  'header': ['   Sessions']       },
  \ ]
endfunction

function! SessionInit()
  let g:startify_custom_header = map(split(system('echo "Session Under"; pwd'), '\n'), '"   ". v:val')
  let g:startify_lists = [
  \ { 'type': 'commands',  'header': ['   Commands']       },
  \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
  \ ]
endfunction

function! SessionClose() abort
  if exists('v:this_session') && filewritable(v:this_session)
    call startify#session_write(fnameescape(v:this_session))
    let v:this_session = ''
  endif
  call startify#session_delete_buffers()
  call UnstartifySession()
  Startify
endfunction

command! -nargs=0 SessionInit call SessionInit()
command! -nargs=0 SessionClose call SessionClose()

nnoremap <leader>Si :SessionInit<cr>
nnoremap <leader>Sc :SessionClose<cr>
nnoremap <leader>Ss :exe 'mksession! ' . fnameescape(v:this_session)<CR>
nnoremap <leader>Se :exe 'edit ' . fnameescape(v:this_session)<CR>

" }}}

" Terminal {{{

if has("nvim")

" open a named tmux session; name argument defaults to name of directory
" containing Session.vim or just name of cwd when not running in a session.
function! OpenTmux(...)
  if a:0 > 0
    let session = a:1
  elseif v:this_session != ""
    let session = fnamemodify(v:this_session, ':h:t')
  else
    let session = fnamemodify(getcwd(), ':t')
  endif

  exe 'terminal tmux new-session -A -s ' . shellescape(session)
  autocmd TermOpen <buffer> startinsert
  autocmd TermClose <buffer> close!
endfunction
command! -nargs=* Tmux call OpenTmux(<f-args>)

" add tmux-aligned bindings, when not running under tmux
if !has_key(environ(), 'TMUX')
  nmap <C-u>z :vert split \| Tmux<CR>
  nmap <C-u>d :Tmux<CR>
  tnoremap <C-u><Esc> <C-\><C-n>
endif

if has('win32')
  let g:termhide_default_shell = 'powershell.exe'
elseif executable('zsh')
  let g:termhide_default_shell = 'zsh'
endif

let g:termhide_hud_size = 15

" Create or show existing terminal buffer
nnoremap <leader>$ :Term<cr>
nnoremap <leader># :TermVSplit<cr>

" Easy HUD toggle
nnoremap <leader>` :TermHUD<cr>
tnoremap <leader>` <C-\><C-n><C-w>c

" Quicker 'Go Back' binding
tnoremap <C-\><C-o> <C-\><C-n><C-o>

" Quicker window operations
tnoremap <C-\><C-c> <C-\><C-n><C-w>c
tnoremap <C-\><C-w> <C-\><C-n><C-w><C-w>
tnoremap <C-\><C-h> <C-\><C-n><C-w>h
tnoremap <C-\><C-j> <C-\><C-n><C-w>j
tnoremap <C-\><C-k> <C-\><C-n><C-w>k
tnoremap <C-\><C-l> <C-\><C-n><C-w>l
tnoremap <C-\>p <C-\><C-n>pi

" Neovim server/remote support
if has('nvim')
  if !exists("$NVIM_LISTEN_ADDRESS")
    call serverstart()
  endif
  if executable('nvr')
    let $EDITOR = 'nvr -cc vsplit --remote-wait'
    let $GIT_EDITOR = $EDITOR
  endif

  augroup delete_git_buffers
    autocmd!
    autocmd FileType gitcommit,gitrebase,gitconfig setlocal bufhidden=delete
  augroup END

  augroup delete_arc_buffers
    autocmd!
    autocmd BufRead,BufNewFile,BufEnter **/edit.*/new-commit,**/edit.*/differential-update-comments setlocal bufhidden=delete
  augroup END
endif

endif

augroup proto_comments
  autocmd!
  autocmd FileType proto setlocal commentstring=//\ %s
augroup END

" }}}

" vim:set foldmethod=marker ts=2 sw=2 expandtab:
