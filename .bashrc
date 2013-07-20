[ -f /etc/bashrc ] && . /etc/bashrc
[ -f ~/.profile ] && . ~/.profile
[ -f ~/.aliases ] && . ~/.aliases

if [ -n "$POWERLINE_BINDINGS" ]; then
    source $POWERLINE_BINDINGS/bash/powerline.sh
else
    export PS1='\u@\h \w\$ '
    if type __git_ps1 &>/dev/null; then
        export GIT_PS1_SHOWDIRTYSTATE=1
        export GIT_PS1_SHOWUPSTREAM="verbose"
        export PS1='\u@\h \w$(__git_ps1 " (%s)")\$ '
    fi
fi
