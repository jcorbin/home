#!/bin/zsh

# Include common shell config
source ~/.profile

if [ -z ${SSH_AUTH_SOCK} ]; then
  SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  if [ -n ${SSH_AUTH_SOCK} ]; then
    export SSH_AUTH_SOCK
    systemctl --user import-environment SSH_AUTH_SOCK
  fi
fi

if [ -z ${DISPLAY} ] && [ -z ${WAYLAND_DISPLAY} ] && [ ${XDG_VTNR} -eq 1 ]; then
  exec river >! ${XDG_RUNTIME_DIR}/river.log 2>&1
fi
