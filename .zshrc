#!/bin/zsh

# Make sure that .profile has been loaded, even if
# there was no "login shell" in our lineage.
if [ -z "$_PROFILE_LOADED" ]; then
    source ~/.profile
else
    # Make sure that we have the array utility functions.
    source ~/.profile.d/arrayutil
fi

# For restoring sanity to MacOS: ~/.profile.d/brew_gnu_path defines re_gnu and
# no_gnu to subvert much of BSD userspace with GNU alternatives. However we
# only default such subversion on for interactive shells, so that we don't
# break scripts written with BSD assumptions.
re_gnu

if [[ -f /usr/share/cachyos-zsh-config/cachyos-config.zsh ]]; then
  source /usr/share/cachyos-zsh-config/cachyos-config.zsh
  # cachyos integrates p10k already, but otherwise look if it's available
else
  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block; everything else may go below.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi

  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

for part in $(~/.local/bin/deporder -f ~/.zsh/rc.d); do
  source $part
done

# So that $HOME skew doesn't go unnoticed for too long
if [[ $(pwd) == $HOME ]]; then
  git -C "$HOME" status --short
fi
