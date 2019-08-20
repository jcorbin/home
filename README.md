# My `$HOME` (there are many like them...)

I use Git to manage my home directory:

- set up to [ignore](.gitignore) everything by default
- and then whitelist what git should track
- notably I do not use any sort of symlink indirection between a "dotfiles
  repository" and `$HOME` itself

Where I do find indirection useful is at review time:

- `$HOME`'s only remote is a local repository, such as `$HOME/home-int`
- `$HOME` is on a context-specific non-master branch (e.g. `patron`,
  `personal`, `server`, etc)
- `$HOME/home-int` then can mediate between various remotes, like:
  - Github for sharing the `master` branch
  - private git servers for `personal` and `patron` branches
- `$HOME` is setup to [automatic checkout when pushed
  into](bin/git-setup-worktree-push)

All of this allows me to:

- quickly commit any changes in `$HOME` before they become forgotten
- reconciliation (merging, rebasing, etc) so that any conflicts or other
  artifacts do not break my actual `$HOME`
- easily separate public vs private changes without much risk of leaking
  private details to Github

# Git

Since much of my workflow as a programmer revolves around managing changes,
my [git config](.gitconfig) is one of the most vital parts of my setup;
especially its `[alias]` section and custom `[pretty]` formats (for `git-log`)

# (Neo)Vim

The only thing I use more than git is my [`$EDITOR`](.profile.d/editor):
[NeoVim][neovim_io] a modernized fork of [Vim][vim_org]

So that I can still use systems without neovim my, I have a a unified
[.vimrc](.vimrc) and [.config/nvim/init.vim](.config/nvim/init.vim)

I try to keep my vim config cleanly organized using manual fold markers, and by
separating out anything beyond simple settings changes into separate plugins

Its [darkula][jcorbin_darkula] color scheme is one that I assembled after
reaching dissatisfaction with other available choices

# Basic Shell Setup: `.profile`, `.bashrc`, and `.zshrc`

While I'm primarily a Zsh user, I do occasionally use bash

I keep a clear separation between between non-shell specific environment in
[`.profile`](.profile) and any shell-specific things in that shell's config

The Zsh config lives in: [`.zshenv`](.zshenv) and [`.zshrc`](.zshrc) with
modules broken out in [`.zsh/`](.zsh)

The Bash config lives in [`.bash_profile`](.bash_profile) and
[`.bashrc`](.bashrc)

Both share a common [`.aliases`](.aliases) file

# Shell Orchestration: TMux (RIP Screen)

I use [TMux][tmux_io] for terminal multiplexing its config is kept in
[`.tmux.conf`](.tmux.conf); including a `darkula` colorscheme

# All The Colors

The color scheme that I use, is one that I assembled called
[darkula][jcorbin_darkula]; it's derived from [Jet Brains
Dracula][jetbrains_dracula], but further darkened a bit

Key to working [24-bit color][xvilka_24bit], especially in like Mac OS X:

- [profile fragment](.profile.d/term) to adjust `$TERM` and...
- ... compile any necessary [terminfo definitions](.terminfo.src/)

Then you can turn up the color in various places:

- [dircolors](.profile.d/dircolors) for `ls` and friends
- [pager](.profile.d/pager) for `less` (used for things like manual pages, git log viewing, etc)
- [zsh syntax highlighting](.zsh/rc.d/highlighting)
- [neovim and vim 8+](.vimrc) support a `termguicolors` feature so that all
  24-bit color schemes Just Work in the terminal

[jcorbin_darkula]: https//:github.com/jcorbin/darkula
[jetbrains_dracula]: https://plugins.jetbrains.com/plugin/12275-dracula-theme
[neovim_io]: https://neovim.io/
[tmux_io]: https://tmux.github.io/
[vim_org]: http://www.vim.org
[xvilka_24bit]: https://gist.github.com/XVilka/8346728
