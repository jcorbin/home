#!/bin/sh

for part in $(~/bin/deporder -f ~/.profile.d); do
	. $part
done

_PROFILE_LOADED=$(date +%s)
export _PROFILE_LOADED
