#!/bin/zsh

# Make sure that .profile has been loaded, even if
# there was no "login shell" in our lineage.
[ -n "$_PROFILE_LOADED" ] || source ~/.profile

# TODO put configs here
