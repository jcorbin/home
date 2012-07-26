#!/bin/sh
set -e
set -x

if [ "$1" != "inner" ]; then
    if which ck-launch-session &>/dev/null; then
        exec ck-launch-session $0 inner "$@"
    else
        exec $0 inner "$@"
    fi
fi

[ -z "$SSH_AUTH_SOCK" ] && exec ssh-agent $0 inner "$@"

session=${2:-awesome}

# Launch dbus if not started
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
   eval $(dbus-launch --sh-syntax --exit-with-session)
fi

$session&
sessionpid=$!

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
setxkbmap dvorak -option ctrl:nocaps

for d in /usr/lib/polkit-gnome /usr/libexec; do
    if [ -x $d/polkit-gnome-authentication-agent-1 ]; then
        $d/polkit-gnome-authentication-agent-1&
        break
    fi
done

#/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh&
/usr/bin/gnome-keyring-daemon --start --components=secrets,ssh&

nm-applet&

xterm -e atmux&

wait $sessionpid
