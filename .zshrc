[ -n "$_PROFILE_LOADED" ] || source ~/.profile

for part in $(~/bin/deporder -f ~/.zsh/rc.d); do
	source $part
done

# For restoring sanity to MacOS: ~/.profile.d/brew_gnu_path defines re_gnu and
# no_gnu to subvert much of BSD userspace with GNU alternatives. However we
# only default such subversion on for interactive shells, so that we don't
# break scripts written with BSD assumptions.
re_gnu

# vim:set ft=zsh:
