" Language:    GorillaScript
" Maintainer:  "UnCO" Lin <undercooled _aT_ lavabit _dOt_ com>
" URL:         http://github.com/unc0/vim-gorilla-script
" License:     WTFPL

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

setlocal formatoptions-=t formatoptions+=croql
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
setlocal commentstring=//%s
setlocal omnifunc=javascriptcomplete#CompleteJS

" Enable GorillaMake if it won't overwrite any settings.
if !len(&l:makeprg)
  compiler gorilla
endif

" Check here too in case the compiler above isn't loaded.
if !exists('gorilla_compiler')
  let gorilla_compiler = 'gorilla'
endif

" Reset the GorillaCompile variables for the current buffer.
function! s:GorillaCompileResetVars()
  " Compiled output buffer
  let b:gorilla_compile_buf = -1
  let b:gorilla_compile_pos = []

  " If GorillaCompile is watching a buffer
  let b:gorilla_compile_watch = 0
endfunction

" Clean things up in the source buffer.
function! s:GorillaCompileClose()
  exec bufwinnr(b:gorilla_compile_src_buf) 'wincmd w'
  silent! autocmd! GorillaCompileAuWatch * <buffer>
  call s:GorillaCompileResetVars()
endfunction

" Update the GorillaCompile buffer given some input lines.
function! s:GorillaCompileUpdate(startline, endline)
  let input = join(getline(a:startline, a:endline), "\n")

  " Move to the GorillaCompile buffer.
  exec bufwinnr(b:gorilla_compile_buf) 'wincmd w'

  " Gorilla doesn't like empty input.
  if !len(input)
    return
  endif

  " Compile input.
  let output = system(g:gorilla_compiler . ' -scpb 2>&1', input)

  " Be sure we're in the GorillaCompile buffer before overwriting.
  if exists('b:gorilla_compile_buf')
    echoerr 'GorillaCompile buffers are messed up'
    return
  endif

  " Replace buffer contents with new output and delete the last empty line.
  setlocal modifiable
    exec '% delete _'
    put! =output
    exec '$ delete _'
  setlocal nomodifiable

  " Highlight as JavaScript if there is no compile error.
  if v:shell_error
    setlocal filetype=
  else
    setlocal filetype=javascript
  endif

  call setpos('.', b:gorilla_compile_pos)
endfunction

" Update the GorillaCompile buffer with the whole source buffer.
function! s:GorillaCompileWatchUpdate()
  call s:GorillaCompileUpdate(1, '$')
  exec bufwinnr(b:gorilla_compile_src_buf) 'wincmd w'
endfunction

" Peek at compiled GorillaScript in a scratch buffer. We handle ranges like this
" to prevent the cursor from being moved (and its position saved) before the
" function is called.
function! s:GorillaCompile(startline, endline, args)
  if !executable(g:gorilla_compiler)
    echoerr "Can't find GorillaScript compiler `" . g:gorilla_compiler . "`"
    return
  endif

  " If in the GorillaCompile buffer, switch back to the source buffer and
  " continue.
  if !exists('b:gorilla_compile_buf')
    exec bufwinnr(b:gorilla_compile_src_buf) 'wincmd w'
  endif

  " Parse arguments.
  let watch = a:args =~ '\<watch\>'
  let unwatch = a:args =~ '\<unwatch\>'
  let size = str2nr(matchstr(a:args, '\<\d\+\>'))

  " Determine default split direction.
  if exists('g:gorilla_compile_vert')
    let vert = 1
  else
    let vert = a:args =~ '\<vert\%[ical]\>'
  endif

  " Remove any watch listeners.
  silent! autocmd! GorillaCompileAuWatch * <buffer>

  " If just unwatching, don't compile.
  if unwatch
    let b:gorilla_compile_watch = 0
    return
  endif

  if watch
    let b:gorilla_compile_watch = 1
  endif

  " Build the GorillaCompile buffer if it doesn't exist.
  if bufwinnr(b:gorilla_compile_buf) == -1
    let src_buf = bufnr('%')
    let src_win = bufwinnr(src_buf)

    " Create the new window and resize it.
    if vert
      let width = size ? size : winwidth(src_win) / 2

      belowright vertical new
      exec 'vertical resize' width
    else
      " Try to guess the compiled output's height.
      let height = size ? size : min([winheight(src_win) / 2,
      \                               a:endline - a:startline + 2])

      belowright new
      exec 'resize' height
    endif

    " We're now in the scratch buffer, so set it up.
    setlocal bufhidden=wipe buftype=nofile
    setlocal nobuflisted nomodifiable noswapfile nowrap

    autocmd BufWipeout <buffer> call s:GorillaCompileClose()
    " Save the cursor when leaving the GorillaCompile buffer.
    autocmd BufLeave <buffer> let b:gorilla_compile_pos = getpos('.')

    nnoremap <buffer> <silent> q :hide<CR>

    let b:gorilla_compile_src_buf = src_buf
    let buf = bufnr('%')

    " Go back to the source buffer and set it up.
    exec bufwinnr(b:gorilla_compile_src_buf) 'wincmd w'
    let b:gorilla_compile_buf = buf
  endif

  if b:gorilla_compile_watch
    call s:GorillaCompileWatchUpdate()

    augroup GorillaCompileAuWatch
      autocmd InsertLeave <buffer> call s:GorillaCompileWatchUpdate()
    augroup END
  else
    call s:GorillaCompileUpdate(a:startline, a:endline)
  endif
endfunction

" Complete arguments for the GorillaCompile command.
function! s:GorillaCompileComplete(arg, cmdline, cursor)
  let args = ['unwatch', 'vertical', 'watch']

  if !len(a:arg)
    return args
  endif

  let match = '^' . a:arg

  for arg in args
    if arg =~ match
      return [arg]
    endif
  endfor
endfunction

" Don't overwrite the GorillaCompile variables.
if !exists('b:gorilla_compile_buf')
  call s:GorillaCompileResetVars()
endif

" Peek at compiled GorillaScript.
command! -range=% -bar -nargs=* -complete=customlist,s:GorillaCompileComplete
\        GorillaCompile call s:GorillaCompile(<line1>, <line2>, <q-args>)
" Run some GorillaScript.
command! -range=% -bar GorillaRun <line1>,<line2>:w !gorilla -s
