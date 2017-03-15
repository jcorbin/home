#!/bin/bash

# Make sure that .profile has been loaded, even if
# there was no "login shell" in our lineage.
if [ -z "$_PROFILE_LOADED" ]; then
    source ~/.profile
else
    # Make sure that we have the array utility functions.
    source ~/.profile.d/arrayutil
fi

# Include system-wide config; Mac OS NOTEs:
# - setting PS1 above will cause this to be a noop
# - the only other effect is a bunch Terminal.app specific integrations...
# - ...so this is especially irrelevant for iTerm2 users
[ -f /etc/bashrc ] && source /etc/bashrc

source ~/.aliases

# TODO put your own config here, maybe even break it up over `.bashrc.d` if
# worth it.
