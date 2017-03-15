#!/bin/zsh

# Make sure that .profile has been loaded, even if
# there was no "login shell" in our lineage.
if [ -z "$_PROFILE_LOADED" ]; then
    source ~/.profile
else
    # Make sure that we have the array utility functions.
    source ~/.profile.d/arrayutil
fi

source ~/.zsh/rc.d/completion
source ~/.zsh/rc.d/editor
source ~/.zsh/rc.d/history
source ~/.zsh/rc.d/highlighting
source ~/.zsh/rc.d/dirnav

source ~/.aliases
