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

# start xdg graphical session if it's not already running
case "$XDG_SESSION_TYPE" in

  wayland)
    if [ -n "$DISPLAY" ]; then
      echo "x11 already seems to be running ( wanted wayland? )"
    elif [ -z "$WAYLAND_DISPLAY" ]; then
      config_desktop_session=$(cat ~/.config/desktop_session)
      desktop_session=${config_desktop_session:-sway}
      case "$desktop_session" in
        plasma)
          exec_session /usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland
          ;;
        *)
          exec_session "$desktop_session"
          ;;
      esac

      echo "Unable to start wayland session ( install a compositor? )"
    fi
    ;;

  x11)
    if [ -n "$WAYLAND_DISPLAY" ]; then
      echo "wayland already seems to be running ( wanted x11? )"
    elif [ -z "$DISPLAY" ]; then
      exec_session startx
      echo "Unable to start x11 session ( install startx? )"
    fi
    ;;

esac
