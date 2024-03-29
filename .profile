#!/bin/bash

# Common shell environment and configuration

for part in $(~/.local/bin/deporder -f ~/.profile.d); do
	. $part
done

# Given the complicated relationship between profile and shell rc,
# and given the assumption "you never don't want your profile setup in an
# interactive shell":
# - each shell profile (e.g. .bash_profile) sources .profile
# - each shell rc (e.g. .bashrc) sources .profile if _PROFILE_LOADED is not
#   set
# - TODO: we could do even better with further compiler support ala
#   github.com/jcorbin/home:
#   - the compiled profile could set define this to a content hash
#   - shell rc could then "reload if modified"
#   - that core "reload if modified" function could also be ran by existing
#     shells lieu of restarting (either at the user's behest, or
#     automagically).
_PROFILE_LOADED=$(date +%s)
export _PROFILE_LOADED
