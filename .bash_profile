#!/bin/bash

# Include common shell config
source ~/.profile

# Restore sanity to bash's exclusive "login or
# interactive" logic; in other words, make it more
# like Zsh's ladder of progressive enhancement.
[ -f ~/.bashrc ] && source ~/.bashrc
