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

" vim:set foldmethod=marker foldlevel=0 ts=2 sw=2 expandtab:
