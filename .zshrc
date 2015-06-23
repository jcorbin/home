export USE_GNU=1
source $HOME/.profile

for part in $(~/bin/deporder -f ~/.zsh/rc.d); do
	source $part
done

# vim:set ft=zsh:
