#!/bin/bash

# Make sure that .profile has been loaded, even if
# there was no "login shell" in our lineage.
[ -n "$_PROFILE_LOADED" ] || source ~/.profile

# TODO put your own config here, maybe even break it up over `.bashrc.d` if
# worth it.

# Include system-wide config; Mac OS NOTEs:
# - setting PS1 above will cause this to be a noop
# - the only other effect is a bunch Terminal.app specific integrations...
# - ...so this is especially irrelevant for iTerm2 users
[ -f /etc/bashrc ] && source /etc/bashrc
