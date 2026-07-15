delay_attempt() {
  local pending_file=$1

  if [ -f "$pending_file" ]; then
    local prior_time=$(date -r"$pending_file" +%s)
    local now=$(date +%s)
    local pend_since=$(( now - prior_time ))

    <"$pending_file" read prior
    local backoff=$(( 2 ** prior - 1 ))

    if [ $pend_since -ge $backoff ]; then
      echo >&2 ".zlogin resetting stale $pending_file prior $prior since $prior_time"
      prior=0
    else
      local delay=$(( backoff - pend_since ))
      echo >&2 ".zlogin sleeping $delay after $prior prior failures"
      sleep $delay
    fi

    echo $(( prior + 1 )) >! "$pending_file"
  else
    echo 1 >"$pending_file"
  fi
}

exec_session() {
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zlogin"
  if [ ! -d "$state_dir" ]; then
    mkdir -p "$state_dir"
  fi

  if [ -n "$AUTOLOGIN" ]; then
    export AUTOLOGIN="${state_dir}/vt${XDG_VTNR}-pending"
    delay_attempt "$AUTOLOGIN"
  fi

  local logfile="${state_dir}/vt${XDG_VTNR}-$(date -Iseconds).log"
  export XDG_SESSION_LOG=$logfile

  ln -svf "$logfile" "${state_dir}/vt${XDG_VTNR}.log"

  echo "Executing $@"
  exec >"$logfile" 2>&1
  echo ".zlogin executing $@"
  exec "$@"
}

# ── Session-launch gating ──────────────────────────────────────────────────
# This file is sourced for *every* zsh login shell.
#
# The autologin prompt + `uwsm start` below are session-bootstrap:
# they should run ONLY from a real VT login, not from terminal emulators that
# spawn a redundant login shell under an existing graphical login session.
#
# $session_launch:
#    1  candidate VT login → run the session-bootstrap path
#    0  login shell where it has no business being → fire the tripwire
if [ "${XDG_SESSION_TYPE-}" = wayland ]; then
  session_launch=1
else
  session_launch=0
fi

# Any gate that trips below clears $session_launch.
# Each only bothers checking while we're still a candidate,
# so already-rejected (0) short-circuit past all of them.

# (a) No compositor yet: a real VT login runs before wayland/X exist;
#     a terminal emulator always has WAYLAND_DISPLAY (or DISPLAY) set.
if [ "$session_launch" = 1 ] && { [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ] }; then
  session_launch=0
fi

# (b) Controlling terminal is a kernel VT (/dev/tty1..N), not a pty
#     (/dev/pts/N) handed to a terminal emulator.
if [ "$session_launch" = 1 ] && [[ "$(tty)" != /dev/tty[0-9]* ]]; then
  session_launch=0
fi

# (c) Not running inside a known terminal emulator (each exports a marker var).
if [ "$session_launch" = 1 ] && [ -n "${WEZTERM_PANE-}${GHOSTTY_RESOURCES_DIR-}${ALACRITTY_WINDOW_ID-}${TERM_PROGRAM-}" ]; then
  session_launch=0
fi

if [ "$session_launch" = 1 ]; then
  if [ -n "$AUTOLOGIN" ] && [ -e "$HOME/autologin.hold" ]; then
    print -P "%B%F{cyan}< Press Enter To Proceed With Auto Login >%f%b"
    read pause
  fi

  if uwsm check may-start -q; then
    exec_session uwsm start default
  fi
elif [ "$session_launch" = 0 ]; then
  # Something spawned a login shell inside an existing session
  # — i.e. a terminal emulator is opening a login scope beneath the compositor,
  # which it should not.
  print -u2 -P "%B%F{yellow}.zlogin: login shell inside an existing session%f%b"
  for var in WAYLAND_DISPLAY DISPLAY WEZTERM_PANE GHOSTTY_RESOURCES_DIR ALACRITTY_WINDOW_ID TERM_PROGRAM; do
    val=${(P)var}
    if [ -n "$val" ]; then
      print -u2 -P "%B%F{yellow}  $var=$val%f%b"
    fi
  done
fi
