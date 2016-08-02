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
