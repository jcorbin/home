" plugins {{{

" setup vim-plug, downloading it if needed
" see https://github.com/junegunn/vim-plug
let $VIMHOME=expand('<sfile>:p:h')
if $VIMHOME == $HOME
  let $VIMHOME=$HOME.'/.vim'
endif
if empty(glob($VIMHOME.'/autoload/plug.vim'))
    silent !curl -fLo $VIMHOME/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin($VIMHOME.'/plugged')

" better defaults out of the box
Plug 'tpope/vim-sensible'

call plug#end()
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
nnoremap / /\v
nnoremap ? ?\v

" }}}

" vimscript editing convenience {{{
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
inoremap <leader>ev <esc>:vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
" }}}

" vim:set foldmethod=marker foldlevel=0 ts=2 sw=2 expandtab:
