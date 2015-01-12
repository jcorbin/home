autoload run-help

if [ "$TERM" = 'xterm' ] && [ "$COLORTERM" = "gnome-terminal" ]; then
	export TERM=xterm-256color
fi

source $HOME/.profile

for part in $(~/bin/deporder -f ~/.zsh/rc.d); do
	source $part
done

# vim:set ft=zsh:
