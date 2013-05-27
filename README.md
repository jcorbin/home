This project adds [GorillaScript] support to the vim editor. It handles syntax,
indenting, compiling, and more. Also included is support for GorillaScript in
HTML.

[GorillaScript]: http://ckknight.github.io/gorillascript/

### Install with Unbundle

Since this plugin has rolling versions based on git commits, using unbundle and
git is the preferred way to install. The plugin ends up contained in its own
directory and updates are just a `git pull` away.

1. Git clone sunaku's [unbundle] into `~/.vim/bundle/` and add this line to your
   `vimrc`:

        runtime bundle/vim-unbundle/unbundle.vim

    To get the all the features of this plugin, make sure you also have a
    `filetype plugin indent on` line in there.

[unbundle]: https://github.com/sunaku/vim-unbundle

2. Create and change into `~/.vim/ftbundle/gorilla`:

        $ mkdir -p ~/.vim/ftbundle/gorilla
        $ cd ~/.vim/ftbundle/gorilla

3. Make a clone of the `vim-gorilla-script` repository:

        $ git clone https://github.com/unc0/vim-gorilla-script.git

#### Updating

1. Change into `~/.vim/ftbundle/gorilla/vim-gorilla-script/`:

        $ cd ~/.vim/ftbundle/gorilla/vim-gorilla-script

2. Pull in the latest changes:

        $ git pull

### GorillaMake: Compile the Current File

The `GorillaMake` command compiles the current file and parses any errors.

The full signature of the command is:

    :[silent] GorillaMake[!] [GORILLA-OPTIONS]...

By default, `GorillaMake` shows all compiler output and jumps to the first line
reported as an error by `gorilla`:

    :GorillaMake

Compiler output can be hidden with `silent`:

    :silent GorillaMake

Line-jumping can be turned off by adding a bang:

    :GorillaMake!

Options given to `GorillaMake` are passed along to `gorilla`:

    :GorillaMake --bare

`GorillaMake` can be manually loaded for a file with:

    :compiler gorilla

#### Recompile on write

To recompile a file when it's written, add an `autocmd` like this to your
`vimrc`:

    au BufWritePost *.gs silent GorillaMake!

All of the customizations above can be used, too. This one compiles silently
and with the `-b` option, but shows any errors:

    au BufWritePost *.gs silent GorillaMake! -b | cwindow | redraw!

The `redraw!` command is needed to fix a redrawing quirk in terminal vim, but
can removed for gVim.

#### Default compiler options

The `GorillaMake` command passes any options in the `gorilla_make_options`
variable along to the compiler. You can use this to set default options:

    let gorilla_make_options = '--bare'

#### Path to compiler

To change the compiler used by `GorillaMake` and `GorillaCompile`, set
`gorilla_compiler` to the full path of an executable or the filename of one
in your `$PATH`:

    let gorilla_compiler = '/usr/bin/gorilla'

This option is set to `gorilla` by default.

### GorillaCompile: Compile Snippets of GorillaScript

The `GorillaCompile` command shows how the current file or a snippet of
GorillaScript is compiled to JavaScript. The full signature of the command is:

    :[RANGE] GorillaCompile [watch|unwatch] [vert[ical]] [WINDOW-SIZE]

Calling `GorillaCompile` without a range compiles the whole file.

Calling `GorillaCompile` with a range, like in visual mode, compiles the selected
snippet of GorillaScript.

This scratch buffer can be quickly closed by hitting the `q` key.

Using `vert` splits the GorillaCompile buffer vertically instead of horizontally:

    :GorillaCompile vert

Set the `gorilla_compile_vert` variable to split the buffer vertically by
default:

    let gorilla_compile_vert = 1

The initial size of the GorillaCompile buffer can be given as a number:

    :GorillaCompile 4

#### Watch (live preview) mode

Watch mode is like the Try GorillaScript preview box on the GorillaScript
homepage.

Writing some code and then exiting insert mode automatically updates the
compiled JavaScript buffer.

Use `watch` to start watching a buffer (`vert` is also recommended):

    :GorillaCompile watch vert

After making some changes in insert mode, hit escape and the GorillaScript will
be recompiled. Changes made outside of insert mode don't trigger this recompile,
but calling `GorillaCompile` will compile these changes without any bad effects.

To get synchronized scrolling of a GorillaScript and GorillaCompile buffer, set
`scrollbind` on each:

    :setl scrollbind

Use `unwatch` to stop watching a buffer:

    :GorillaCompile unwatch

### GorillaRun: Run some GorillaScript

The `GorillaRun` command compiles the current file or selected snippet and runs
the resulting JavaScript. Output is shown at the bottom of the screen.

### Configure Syntax Highlighting

Add these lines to your `vimrc` to disable the relevant syntax group.

#### Disable trailing whitespace error

Trailing whitespace is highlighted as an error by default. This can be disabled
with:

    hi link GorillaSpaceError NONE

### Tune Vim for GorillaScript

Changing these core settings can make vim more GorillaScript friendly.

#### Fold by indentation

Folding by indentation works well for GorillaScript functions and classes.

To fold by indentation in GorillaScript files, add this line to your `vimrc`:

    au BufNewFile,BufReadPost *.gs setl foldmethod=indent nofoldenable

With this, folding is disabled by default but can be quickly toggled per-file
by hitting `zi`. To enable folding by default, remove `nofoldenable`:

    au BufNewFile,BufReadPost *.gs setl foldmethod=indent

#### Two-space indentation

To get standard two-space indentation in GorillaScript files, add this line to
your `vimrc`:

    au BufNewFile,BufReadPost *.gs setl shiftwidth=2 expandtab

### Cooperate with other plugins

[NERDCommenter]

    let g:NERDCustomDelimiters.gorilla = {
          \ 'left': '//',
          \ 'leftAlt': '/*',
          \ 'rightAlt': '*/',
          \}

[Phrase]

    let g:phrase_ft_tbl.gorilla = {
          \ "ext": "gs",
          \ "cmt": ["/*", "*/"]
          \}

[Syntastic]

*You should comment this autocmd out in your vimrc:*

    " au BufWritePost *.gs silent GorillaMake!

1. Install Syntastic:

        $ cd ~/.vim/bundle
        $ git clone https://github.com/scrooloose/syntastic.git

2. Copy the checker to syntastic:

        $ mkdir -p syntastic/syntax_checkers/gorilla
        $ cd syntastic/syntax_checkers/gorilla
        $ ln -s ~/.vim/ftbundle/gorilla/vim-gorilla-script/syntastic_checker/gorilla.vim

[NERDCommenter]: https://github.com/scrooloose/nerdcommenter
[Phrase]: https://github.com/t9md/vim-phrase
[Syntastic]: https://github.com/scrooloose/syntastic
