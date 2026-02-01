#!/bin/zsh

# Make sure that .profile has been loaded, even if
# there was no "login shell" in our lineage.
if [ -z "$_PROFILE_LOADED" ]; then
    source ~/.profile
else
    # Make sure that we have the array utility functions.
    source ~/.profile.d/arrayutil
fi

for part in $(~/.local/bin/deporder -f ~/.zsh/rc.d); do
  source $part
done

setopt no_correct_all

if [ -d /usr/share/nvm ]; then
  . /usr/share/nvm/nvm.sh
  . /usr/share/nvm/bash_completion
fi

# OpenClaw Completion
source <(openclaw completion --shell zsh)
