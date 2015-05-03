call pathogen#infect()
call pathogen#helptags()

" Options {{{

set cursorline
set expandtab
set foldmethod=indent
set list
set nocompatible " This is an "option" apparently...
set scrolloff=3 " Try to keep 3 lines after cursor
set shiftwidth=4
set smartindent
set spell
set splitbelow
set splitright
set swapsync=
set tabstop=4
set undolevels=1000
set virtualedit=all
set wildmode=longest,list:longest

"}}}

" searching {{{
set ignorecase " Do case insensitive matching...
set smartcase  " ...but only if the user didn't explicitly case
set hlsearch   " highlight while searching

" disable hlsearch in insert mode
augroup hlsearch
autocmd InsertEnter * :setlocal nohlsearch
autocmd InsertLeave * :setlocal   hlsearch
augroup END
"}}}

" Persistent undo (vim 7.3+) {{{
if has("persistent_undo")
  set undodir=$HOME/.vim/undo
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
  colorscheme molokai
" }}}
" Terminal options {{{
else
  if $TERM =~ 'xterm' || $TERM =~ 'screen'
    set ttyfast
  endif

  " Determine colorscheme
  if &t_Co == 256
    let g:rehash256 = 1
    colorscheme molokai
  else
    if $BACKGROUND == 'light'
      set background=light
    else
      set background=dark
    endif
    colorscheme desert
  endif

endif
" }}}

" spell check in git mode {{{
augroup git
autocmd Filetype gitcommit setlocal spell textwidth=72
augroup END
" }}}

" use syntax folding in markdown {{{
augroup markdown
autocmd BufRead,BufNewFile *.md setlocal filetype=markdown foldmethod=syntax
augroup END
" }}}

" Mappings {{{

let mapleader=","

" vimscript editing convenience {{{
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
inoremap <leader>ev <esc>:vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>s% :source %<cr>
" }}}

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

" easier re-sync for lazy diff algorithm
nnoremap du :diffupdate<cr>

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

" TagBar {{{
nnoremap <leader>tg :TagbarToggle<cr>
" }}}

" Tabular {{{
nnoremap <leader>tt :Tab<cr>
nnoremap <leader>t= :Tab/=/<cr>
nnoremap <leader>t, :Tab/,/<cr>
nnoremap <leader>t: :Tab/:/<cr>
" }}}

" File/buffer  browsing {{{

" Unite {{{

let g:unite_enable_start_insert = 0

" Yank source
let g:unite_source_history_yank_enable = 1
let g:unite_source_history_yank_save_clipboard = 1

" To track long mru history.
let g:unite_source_file_mru_long_limit = 3000
let g:unite_source_directory_mru_long_limit = 3000

" Mappings
nnoremap <leader>u <Nop>
nnoremap <leader>ub :Unite -complete -no-split buffer_tab buffer<cr>
nnoremap <leader>u" :Unite -complete -no-split register<cr>
nnoremap <leader>uy :Unite -complete -no-split history/yank<cr>
nnoremap <leader>u. :Unite -complete -no-split file_mru file_rec/async:!<cr>
nnoremap <leader>u% :UniteWithBufferDir -complete -no-split file_mru file_rec/async:!<cr>

" }}}

let g:netrw_liststyle = 3

" Moar vineager!
nmap _ <Plug>VinegarVerticalSplitUp

" }}}

" GUndo {{{
nnoremap <leader>gu :GundoToggle<CR>
" }}}

" Syntastic {{{
let g:syntastic_check_on_open = 1
let g:syntastic_aggregate_errors = 1
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_always_populate_loc_list = 1
" }}}

" Lightline {{{

let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ], ['ctrlpmark'] ],
      \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'MyFugitive',
      \   'filename': 'MyFilename',
      \   'fileformat': 'MyFileformat',
      \   'filetype': 'MyFiletype',
      \   'fileencoding': 'MyFileencoding',
      \   'mode': 'MyMode',
      \   'ctrlpmark': 'CtrlPMark',
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \ },
      \ 'subseparator': { 'left': '|', 'right': '|' }
      \ }

function! MyModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help' && &readonly ? 'RO' : ''
endfunction

function! MyFilename()
  let fname = expand('%:t')
  return fname == 'ControlP' ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
        \ &ft == 'unite' ? unite#get_status_string() :
        \ &ft == 'vimshell' ? vimshell#get_status_string() :
        \ ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let mark = ''  " edit here for cool mark
      let _ = fugitive#head()
      return strlen(_) ? mark._ : ''
    endif
  catch
  endtry
  return ''
endfunction

function! MyFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == 'ControlP' ? 'CtrlP' :
        \ fname == '__Gundo__' ? 'Gundo' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ &ft == 'unite' ? 'Unite' :
        \ &ft == 'vimfiler' ? 'VimFiler' :
        \ &ft == 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! CtrlPMark()
  if expand('%:t') =~ 'ControlP'
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ''
  endif
endfunction

let g:ctrlp_status_func = {
  \ 'main': 'CtrlPStatusFunc_1',
  \ 'prog': 'CtrlPStatusFunc_2',
  \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, ...) abort
    let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.c,*.cpp call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction

let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0
let g:vimshell_force_overwrite_statusline = 0

" }}}

:autocmd FileType javascript :iabbrev <buffer> vst var self = this;

" vim:set foldmethod=marker foldlevel=0 ts=2 sw=2 expandtab:
