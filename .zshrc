re_gnu

for part in $(~/bin/deporder -f ~/.zsh/rc.d); do
	source $part
done

# vim:set ft=zsh:
