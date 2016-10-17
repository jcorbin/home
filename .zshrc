#!/bin/zsh

# Make sure that .profile has been loaded, even if
# there was no "login shell" in our lineage.
if [ -z "$_PROFILE_LOADED" ]; then
    source ~/.profile
else
    # Make sure that we have the array utility functions.
    source ~/.profile.d/arrayutil
fi

if [ -n "$TIME_ZSHRC" ]; then
    ~/bin/deporder -timed -out ~/.zsh/rc.d/.cached.timed ~/.zsh/rc.d
    source ~/.zsh/rc.d/.cached.timed
else
    if [ -x ~/bin/deporder ]; then
        ~/bin/deporder -out ~/.zsh/rc.d/.cached ~/.zsh/rc.d
    fi
    if [ -f ~/.zsh/rc.d/.cached ]; then
        source ~/.zsh/rc.d/.cached
    fi
fi

# For restoring sanity to MacOS: ~/.profile.d/brew_gnu_path defines re_gnu and
# no_gnu to subvert much of BSD userspace with GNU alternatives. However we
# only default such subversion on for interactive shells, so that we don't
# break scripts written with BSD assumptions.
re_gnu

# So that $HOME skew doesn't go unnoticed for too long
git -C "$HOME" status --short

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ~/.zsh/iterm2.zsh ] && source ~/.zsh/iterm2.zsh
