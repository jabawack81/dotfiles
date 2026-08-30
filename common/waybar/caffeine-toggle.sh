#!/bin/bash
# Power state control: normal → caffeine → remote → hibernate → normal
#
# Each state runs hypridle with a different config, or kills it for caffeine:
#   normal     standard idle timers
#   caffeine   no hypridle at all, screen never sleeps
#   remote     short idle timers, no suspend/hibernate (reachable over the network)
#   hibernate  short idle timers, then hibernate
#
# Usage:
#   caffeine-toggle.sh              cycle to the next state (bar left-click)
#   caffeine-toggle.sh reset        go straight to normal (bar right-click)
#   caffeine-toggle.sh <state>      set one directly, e.g. from Hyprland autostart
#
# The state file lives in XDG_RUNTIME_DIR, which is tmpfs — so the state is
# deliberately not persisted across reboots. Machines that want to come up in
# something other than normal say so in their own autostart.

STATE_FILE="${XDG_RUNTIME_DIR:-$HOME/.cache}/caffeine-state"
CONF_DIR="$HOME/.config/hypr_common"

restart_hypridle() {
    pkill -x hypridle 2>/dev/null
    sleep 0.3
    if [[ -n "${1:-}" ]]; then
        setsid hypridle -c "$1" >/dev/null 2>&1 &
    else
        setsid hypridle >/dev/null 2>&1 &
    fi
}

apply_state() {
    case "$1" in
        normal)    restart_hypridle ;;
        caffeine)  pkill -x hypridle 2>/dev/null ;;
        remote)    restart_hypridle "$CONF_DIR/hypridle-remote.conf" ;;
        hibernate) restart_hypridle "$CONF_DIR/hypridle-hibernate.conf" ;;
        *)         echo "unknown state: $1" >&2; return 1 ;;
    esac
    echo "$1" > "$STATE_FILE"
}

next_state() {
    case "$1" in
        normal)   echo caffeine ;;
        caffeine) echo remote ;;
        remote)   echo hibernate ;;
        *)        echo normal ;;
    esac
}

# The bar passes "" to cycle and "reset" to go back to normal; keep both.
case "${1:-}" in
    "")     target=$(next_state "$(cat "$STATE_FILE" 2>/dev/null || echo normal)") ;;
    reset)  target=normal ;;
    normal|caffeine|remote|hibernate) target="$1" ;;
    *)
        echo "Usage: $(basename "$0") [reset|normal|caffeine|remote|hibernate]" >&2
        exit 2
        ;;
esac

apply_state "$target" || exit 1

sleep 0.3
# Nudge waybar's custom module to re-read the state file. quickshell polls it
# on a timer instead, so it needs no signal.
pkill -RTMIN+9 waybar 2>/dev/null

exit 0
