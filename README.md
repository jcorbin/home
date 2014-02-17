# searchmatch.vim

Makes :match et al easier to use.

So if you're a frequent user of Vim's `hlsearch` feature, you may find yourself
wishing that you could highlight multiple searches.  Well Vim has support for
this in its `:match` command, but doesn't make that particularly easy to use.

This plugin aims to put the full power of Vim's `:match` feature at the user's
fingertips in the easiest way possible: as an extension of the existing search
feature that you know and love.

You just search for something, and then pin that search with one of the
`SearchMatchN` commands or key mappings.

## Usage

The plugin defines 4 new commands:
- `SearchMatch1`     -- sets the current search as first match
- `SearchMatch2`     -- sets the current search as second match
- `SearchMatch3`     -- sets the current search as third match
- `SearchMatchReset` -- clears all matches set by the `searchmatch` plugin

Unless you've already defined a mapping for `<leader>/`, then the default
normal mappings are:
- `<leader>/`  -- calls SearchMatch1
- `<leader>2/` -- calls SearchMatch2
- `<leader>3/` -- calls SearchMatch3
- `<leader>-/` -- calls SearchMatchReset

If you don't want the default mappings added, add this to `.vimrc`:

    let g:searchmatch_nomap = 1

Additionally the user can run any of the stock match commands (`:match`,
`:2match`, and `:3match`) to turn off any of the three highlights individually.

## Highlighting

The `searchmatch` plugin makes use of `Match1`, `Match2`, and `Match3`
highlighting groups for `:match`, `:2match`, and `:3match` respectively.

Since most colorscheme don't define these highlighting groups, default links
are setup to the standard `ErrorMsg`, `DiffDelete`, and `DiffAdd` groups.

The user will almost certainly want to define these highlight groups in their
`.vimrc` and/or patch their favorite colorscheme(s) (see for example the
author's patched [lucius.vim][0]).

## About `3match`

So the third match is used by other plugins, such as `matchparen`.  But the
notion of this plugin is to give the user as much direct control over as much
match highlighting as possible.

So the `SearchMatch3` command will first disable the `matchparen` plugin if it
is loaded.  Correspondingly the `SearchMatchReset` command will reload the
`matchparen` plugin if `SearchMatch3` unloaded it.

## Installation

Typical [pathogen][1] installation:

    cd ~/.vim/bundle
    git clone https://github.com/jcorbin/vim-searchmatch

Otherwise just copy `plugin/searchmatch.vim` into `~/.vim/plugin/searchmatch.vim`.

## TODO

- can do better with the default highlight definitions?
- other usage patterns, like an operator-pending mapping
- fix glitch when calling `NoMatchParen` in `SearchMatch3`

## License

MIT License. Copyright (c) 2014 Joshua T Corbin.

[0]: https://github.com/jcorbin/home/blob/master/.vim/bundle/lucius/colors/lucius.vim
[1]: https://github.com/tpope/vim-pathogen
