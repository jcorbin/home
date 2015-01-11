# Display fortune
if (( $+commands[fortune] )) && [ ! -f ~/.hushlogin ] && [ ! -f ~/.no_fortune_motd ]; then
  echo
  fortune -a | sed -e 's/^/    /'
  echo
fi
