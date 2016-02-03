# Display fortune
if (( $+commands[fortune] )) && [[ -t 1 ]] && [[ ! -f ~/.hushlogin ]] && [[ ! -f ~/.demo-mode ]]; then
  echo
  fortune -a | sed -e 's/^/    /'
  echo
fi
