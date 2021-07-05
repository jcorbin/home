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

" better affordance for fF and tT movements
Plug 'unblevable/quick-scope'

" unicode
Plug 'chrisbra/unicode.vim'

" colorschemes
Plug 'pR0Ps/molokai-dark'      " high contrast
Plug 'jcorbin/darkula'         " medium contrast (darker version of IDEA's darcula)
Plug 'robertmeta/nofrils'      " the 'no color' colorscheme
Plug 'chriskempson/base16-vim' " framework of many 16-color themes
Plug 'cocopon/iceberg.vim'     " blue theme
Plug 'w0ng/vim-hybrid'         " lower contrast, tomorrow-esque scheme (feels like a muted molokai)

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/telescope.nvim'

" Lobster!
Plug 'jcorbin/vim-lobster'

Plug 'jcorbin/neovim-termhide'

" Golang support
Plug 'fatih/vim-go'

" Modern Java/typescript support
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'jonsmithers/vim-html-template-literals'

" snippets
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'honza/vim-snippets'

" useful starting screen (load MRU file, fortune, etc)
Plug 'mhinz/vim-startify'

" git integration
Plug 'tpope/vim-fugitive'

" line things up
Plug 'godlygeek/tabular'

" Undo history navigation
Plug 'mbbill/undotree'

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
Plug 'neovim/nvim-lspconfig'

Plug 'Shougo/neco-vim'
Plug 'Shougo/neco-syntax'
Plug 'Shougo/neoinclude.vim'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

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
set shiftround      " round to shiftwidth
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

  augroup hl_on_yank
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank {timeout=250}
  augroup END

endif

" quick-scope when fFtT moves are pending
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" }}}

" Telescope {{{

nnoremap <Leader>en <cmd>lua require'telescope.builtin'.find_files{ cwd = "~/.config/nvim/" }<CR>
nnoremap <Leader>p <cmd>lua require'telescope.builtin'.git_files{}<CR>
" nnoremap <Leader>p <cmd>lua require'telescope.builtin'.find_files{}<CR>
" require'telescope.builtin'.buffers{)

" }}}

if has("nvim")

" Treesitter {{{

lua <<EOF

require'nvim-treesitter.configs'.setup {

  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages

  highlight = {
    enable = true,             -- false will disable the whole extension
    -- disable = { "c", "rust" }, -- list of language that will be disabled
  },

  incremental_selection = {
    enable = false,
    keymaps = {                       -- mappings for incremental selection (visual mappings)
      init_selection = "gnn",         -- maps in normal mode to init the node/scope selection
      node_incremental = "grn",       -- increment to the upper named parent
      scope_incremental = "grc",      -- increment to the upper scope (as defined in locals.scm)
      node_decremental = "grm",       -- decrement to the previous node
    },
  },

  indent = {
    enable = false
  },

}
EOF

" TODO treesitter statusline integration
" require'nvim-treesitter'.statusline(size)

" }}}

" LSP {{{

" Setup servers {{{
lua << EOF

local lspconfig = require'lspconfig'

-- npm i -g eslint_d
-- go get mattn/efm-langserver
local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true
}

-- lspconfig.bashls.setup{}
lspconfig.cssls.setup{}
lspconfig.efm.setup{
  init_options = {documentFormatting = true},
  settings = {
    rootMarkers = {".git/"},
    languages = {
      javascript = {eslint},
      javascriptreact = {eslint},
      ["javascript.jsx"] = {eslint},
      typescript = {eslint},
      ["typescript.tsx"] = {eslint},
      typescriptreact = {eslint}
    },
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescript.tsx",
    "typescriptreact"
  },
}
lspconfig.gopls.setup{}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
lspconfig.html.setup {
  capabilities = capabilities,
}

lspconfig.jsonls.setup{}
lspconfig.pyright.setup{}
lspconfig.tsserver.setup{}
lspconfig.vimls.setup{}
lspconfig.yamlls.setup{}

EOF

" register omnifuncs that have no larger language plugin
autocmd Filetype vim setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype sh setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype bash setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype python setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype javascript setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype typescript setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype html setlocal omnifunc=v:lua.vim.lsp.omnifunc

" }}}

nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
" TODO vim.lsp.diagnostic.show_line_diagnostics()

nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>

nnoremap <silent> gR    <cmd>lua vim.lsp.buf.rename()<CR>
" nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
" nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
" nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

nnoremap <silent> gr    <cmd>lua require'telescope.builtin'.lsp_references{}<CR>
nnoremap <silent> g0    <cmd>lua require'telescope.builtin'.lsp_document_symbols{}<CR>
nnoremap <silent> gW    <cmd>lua require'telescope.builtin'.lsp_workspace_symbols{}<CR>

nnoremap <silent> g!    <cmd>lua vim.lsp.util.show_line_diagnostics()<CR>

nnoremap <silent> <leader>f    <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <silent> <leader>a    <cmd>lua vim.lsp.buf.code_action()<CR>

" highlight references on cursor hold/move
set updatetime=300
augroup lsp_refs
  autocmd!
  autocmd CursorHold  * silent! lua vim.lsp.buf.document_highlight()
  autocmd CursorHoldI * silent! lua vim.lsp.buf.document_highlight()
  autocmd CursorMoved * silent! lua vim.lsp.buf.clear_references()
augroup END

augroup lsp_diags
  autocmd!
  " autocmd CursorHold * silent! lua vim.lsp.diagnostic.show_line_diagnostics()
  autocmd User LspDiagnosticsChanged silent! lua vim.lsp.diagnostic.set_loclist{open_loclist = false}
augroup END

" nnoremap <silent> <leader>l :LspDocumentDiagnostics<CR>
" nnoremap <silent> <leader>r :LspRename<CR>
" nnoremap <silent> <leader>e :LspNextError<CR>

" }}}

endif

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

" open one fold level initially, rather than all closed or open
set foldlevelstart=1

" default to indent folding
set foldmethod=indent

" syntax folding for some filetypes {{{
augroup syntax_folding
  autocmd!

  autocmd FileType go setlocal foldmethod=syntax
  autocmd FileType json setlocal foldmethod=syntax
  autocmd FileType javascript setlocal foldmethod=syntax
  autocmd FileType typescript setlocal foldmethod=syntax
  autocmd FileType css setlocal foldmethod=syntax

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

let g:go_gopls_use_placeholders = v:false
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
imap <C-e>     <Plug>(neosnippet_expand)
smap <C-e>     <Plug>(neosnippet_expand)
xmap <C-e>     <Plug>(neosnippet_expand_target)
imap <C-j>     <Plug>(neosnippet_jump)

" For conceal markers.
set conceallevel=1
set concealcursor=niv

augroup noconceal
  autocmd!
  autocmd FileType markdown setlocal conceallevel=0
  autocmd FileType json setlocal conceallevel=0
augroup END

" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
let g:neosnippet#snippets_directory=$VIMHOME.'/plugged/vim-snippets/snippets'

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

" global shortcuts for quick edits {{{

function! SplitTmp(name) abort
  execute 'vsplit ' . a:name
  setlocal bufhidden=delete
endfunction

command! -nargs=1 SplitTmp call SplitTmp(<f-args>)

" vimrc
nnoremap <leader>ve :SplitTmp $MYVIMRC<cr>
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

" colorscheme {{{

if has("termguicolors")
  set termguicolors
endif

set background=dark

let g:nofrils_strbackgrounds=1
let g:darkula_emphasis = 3

colorscheme darkula

" }}}

" Cursor {{{

" blinking, shape changing, and color changing (requires colorscheme support)
set guicursor
      \=a:block
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

" Neovim Terminal {{{
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

  " server/remote support
  if !exists("$NVIM_LISTEN_ADDRESS")
    call serverstart()
  endif
  if executable('nvr')
    let $EDITOR = 'nvr -cc vsplit --remote-wait'
    let $GIT_EDITOR = $EDITOR
  endif

endif " Neovim Terminal }}}

" Auto delete ephemeral buffers when hidden {{{
augroup auto_delete_buffers
  autocmd!
  autocmd FileType gitcommit,gitrebase,gitconfig setlocal bufhidden=delete
  autocmd FileType man setlocal bufhidden=delete
  autocmd BufRead,BufNewFile,BufEnter **/edit.*/new-commit,**/edit.*/differential-update-comments setlocal bufhidden=delete
augroup END
" }}}

augroup proto_comments
  autocmd!
  autocmd FileType proto setlocal commentstring=//\ %s
augroup END

" vim:set foldmethod=marker ts=2 sw=2 expandtab:
