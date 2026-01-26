#!/bin/bash

# Make sure that .profile has been loaded, even if
# there was no "login shell" in our lineage.
if [ -z "$_PROFILE_LOADED" ]; then
    source ~/.profile
else
    # Make sure that we have the array utility functions.
    source ~/.profile.d/arrayutil
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Include system-wide config; Mac OS NOTEs:
# - setting PS1 above will cause this to be a noop
# - the only other effect is a bunch Terminal.app specific integrations...
# - ...so this is especially irrelevant for iTerm2 users
[ -f /etc/bashrc ] && source /etc/bashrc

source ~/.aliases

if [ -f ~/.promptline.sh ]; then
    source ~/.promptline.sh
else
    export PS1='\u@\h \w\$ '
    if type __git_ps1 &>/dev/null; then
        export GIT_PS1_SHOWDIRTYSTATE=1
        export GIT_PS1_SHOWUPSTREAM="verbose"
        export PS1='\u@\h \w$(__git_ps1 " (%s)")\$ '
    fi
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if [ -d /usr/share/nvm ]; then
  . /usr/share/nvm/nvm.sh
  . /usr/share/nvm/bash_completion
fi
