# How I Manage My Home

Simply put: it's a git repository.

There's no indirection between `$HOME` and it change tracking.

I use Git with a twist:
- I've set it up to [ignore](.gitignore) everything by default
- I then whitelist what git should care about

Finally use a few other twists around git:
- `$HOME`'s only remote is a local repository, such as `$HOME/home-int`
- `$HOME` is on a context-specific non-master branch (e.g. `patron`,
  `personal`, `server`, etc)
- `$HOME/home-int` has the remotes you'd expect:
  - Github for the master branch
  - Linode for any personal branches
  - private git server for patron branches

I also use automatic worktree updating on push, as setup by my
[git-setup-worktree-push](bin/git-setup-worktree-push) script.

All of this allows me to:
- quickly commit any changes in `$HOME` before they become forgotten
- reconciliation (merging, rebasing, etc) so that any conflicts or other
  artifacts do not break my actual `$HOME`
- easily separate public vs private changes without much risk of leaking
  private details to Github

# Basic Shell Setup: `.profile`, `.bashrc`, and `.zshrc`

First off, I'm primarily a Zsh user, but also have to use bash on occasion.

Because of this, there's a clear separation between non-shell specific
environment in [`.profile`](.profile), and any shell-specific things in that
shell's rc file.

There's also a shared [`.aliases`](.aliases) file between bash and zsh (TODO:
I've never cared enough about my bash to fragment its rc, probably should get
on that).

Rather than manage a monolithic dot file, I keep my [`.profile`](.profile) and
[`.zshrc`](.zshrc) fragmented into [`.profile.d/`](.profile.d) and
[`.zsh/rc.d/`](.zsh/rc.d) respectively.

So that I don't get into a manual numeric-prefixing game, I declare fragment
dependencies in comments in each fragment; for example, I could have a file
`.profile.d/bar`:

    # after: foo
    export BAR_THING="$FOO_THING"

Since the `bar` fragment depends on the `foo` fragemnet to define `$FOO_THING`.
There is also a corresponding `# before: ...` form so that a dependency can
inject itself before a dependant.

Dependency and dependant names don't have to actually be concrete files; for
example in my [`.profile.d`](.profile.d) I have a virtual `bootstrap` dependant
for early fragments such as [`hostname`](.profile.d/hostname) and
[`locale`](.profile.d/locale).

Dependency resolution is done by a simple [python script](bin/deporder) driving
a simple `for part in ...; do source $part; done` loop.

# Shell Orchestration: TMux (RIP Screen)

I use [TMux](https://tmux.github.io/) for terminal multiplexing; its config is
kept in [`.tmux.conf`](.tmux.conf) with an additional include [statusline
styling](.tmux-dark.conf).

I do also have mouldering [`.screenrc`](.screenrc) from a long time ago.
