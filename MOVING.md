# Moving In

The `starter_home` repository is meant to be used in primarily two different
ways:

1. forking it and starting a brand new `$HOME` repo
2. merging it into an existing `$HOME` (maybe with a pre-existing repo, but
   we'll first create one if you don't have one.)

Since the "fork it and start over" approach is fairly easy, the rest of this
guide will focus on option 2.  You might choose this choice if:

- you have a pre-existing `$HOME` repo, and want to preserve history
- irrespective of prior repo, you want to audit `starter_home`s configs against
  your previous ones
- finally, even if you don't have much in the way of previous configs, maybe
  your patron has some standard `$HOME` template that you want to treat
  similarly to the last

## Packing

First of all `$HOME` needs to be a Git repository; if it isn't already:

- run `git init $HOME`
- copy `starter_home`'s `.gitignore` file into `$HOME/.gitignore`
- run `git add .`
- review what's about to be added with `git status`
  - use `git rm --cached` to un-add anything that shouldn't have been
  - maybe update `.gitignore` to also ignore it
- commit with something like `git commit -m 'Import Prior'`

## Setting Up

Now that you have a Git repo in `$HOME` it's time to setup a "staging" or
"integration" repository.  Especially during the initial move, you're going to
have substantial merge conflicts betwen your prior home and `starter_home`.
Keeping such artifacts out of `$HOME` itself provides you the room to review
them without undue pressure.  We'll call this "integration repo" `~/home-int`
from here on out (you can of course call it anything you want).

For various reasons the branch that you keep checked out in `$HOME` shouldn't
be `master`.  If you followed the steps above to create a `$HOME` repo, you'll
need to rename the branch at this stage.  For a work computer for example, a
pattern like `PATRON-ROLE` works well, where `ROLE` could be something like
`mac` or `server`, and `PATRON` is the name of whoever pays your bills.

To set it up:

- if the current branch in `$HOME` (as seen by `git branch`) is still master,
  rename it using `git branch -m master NAME`; for guidance choosing `NAME`,
  see above
- run `git clone -o local -b BRANCH_NAME $HOME ~/home-int`
- from here, we're working in `~/home-int`, so `cd ~/home-int`
- run `git remote add starter https://github.com/jcorbin/starter_home` add a remote for `starter_home`
- run `git fetch starter` to setup its remote tracking branches

Note we intentionally leave `~/home-int`'s `origin` remote free for you to define:

- its remote for `$HOME` is `local`
- its remote for `starter_home` is `starter`
- the `origin` remote then is free for you to define

## The Move

Now that you have `~/home-int` setup with your prior home and `starter_home`,
all that's left is to merge them.  Run `git merge --allow-unrelated-histories
starter/master` and then look at `git status`, you'll probably see many
conflicts, for example:

```shell
$ git status
On branch PATRON-mac
Your branch is up-to-date with 'local/PATRON-mac'.
You have unmerged paths.

Changes to be committed:
        new file:   .gitmodules
        new file:   .profile.d/arrayutil
        new file:   .profile.d/dircolors
        new file:   .profile.d/editor
        new file:   .profile.d/home_path
        new file:   .profile.d/hostname
        new file:   .profile.d/locale
        new file:   .profile.d/pager
        new file:   .profile.d/sbin_path
        new file:   .profile.d/term
        new file:   .ssh/config
        new file:   .zsh/rc.d/completion
        new file:   .zsh/rc.d/dirnav
        new file:   .zsh/rc.d/editor
        new file:   .zsh/rc.d/highlighting
        new file:   .zsh/rc.d/history
        new file:   .zsh/zsh-completions
        new file:   .zsh/zsh-history-substring-search
        new file:   .zsh/zsh-syntax-highlighting

Unmerged paths:
        both added:      .aliases
        both added:      .bash_profile
        both added:      .bashrc
        both added:      .config/nvim/init.vim
        added by them:   .dircolors/solarized
        both added:      .gitconfig
        both added:      .inputrc
        both added:      .profile
        both added:      .tmux.conf
        both added:      .vimrc
        both added:      .zprofile
        both added:      .zshrc
        both added:      bin/.gitignore
```

Now "all" that's left is to resolve the conflicts; one way to do that is with
`git mergetool --tool vimdiff`.  Once that's all done just `git commit` the
result.

Now it's time to finalize the move!

## Back To `$HOME`

At this point you could "just" pull `~/home-int`'s branch back into `$HOME`.
However I've found it much more effective to setup `$HOME` to accept pushing
directly to its checked out branch (if and only if it's safe to do so!)

To setup `$HOME` to accept pushing into its working tree:
- download [this post-receive][wt_post_rec_hook] git hook, copy it to `$HOME/.git/hooks/post-receive`
- download [this update][wt_post_rec_hook] git hook, copy it to `$HOME/.git/hooks/update`
- make sure that both are executable, run `chmod +x $HOME/.git/hooks/{post-receive,update}`
- finally configure `$HOME` to allow pushing, run `git --git-dir=$HOME/.git config receive.denyCurrentBranch ignore`

For what it's worth my [~/bin/git-setup-worktree-push][git-setup-worktree-push]
script does exactly that.

# Life In Your New Home

TODO: flesh this out, some things to do:

- add an `origin` remote to `~/home-int`, push your merged branch there so that
  it survives the demise of your notebook; if you home contains patron-internal
  details, this should be an internal code server
- prepare a sanitize / cauterized branch, publish it to github, re-integrate
  it; useful for removing patron-internal details or hacks that you're not yet
  fully enamored of
- keeping in sync with future `starter_home` progress

[wt_post_rec_hook]: https://github.com/jcorbin/home/blob/master/bin/githook-update-worktree-post-receive
[wt_update_hook]: https://github.com/jcorbin/home/blob/master/bin/githook-update-worktree-update
[git-setup-worktree-push]: https://github.com/jcorbin/home/blob/master/bin/git-setup-worktree-push
