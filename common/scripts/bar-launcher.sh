#!/bin/bash
# Launch the user's preferred status bar (waybar or quickshell).
# Preference comes from $BAR (greetd session) or ~/.cache/preferred-bar.
# Falls back to waybar if anything goes wrong — waybar is the safe default.
#
# Used by Hyprland exec-once; also called by bar-switch.sh at runtime.

set -u

PREF_FILE="$HOME/.cache/preferred-bar"

# Resolve the preference. An explicit $BAR (set by the greetd session entries)
# wins and is persisted to PREF_FILE so it becomes the single source of truth —
# the quickshell respawn loop below keys off PREF_FILE to tell a crash (respawn)
# apart from a deliberate bar switch (stop).
bar="${BAR:-}"
if [[ -n "$bar" ]]; then
    mkdir -p "$(dirname "$PREF_FILE")"
    echo "$bar" > "$PREF_FILE"
elif [[ -f "$PREF_FILE" ]]; then
    bar=$(cat "$PREF_FILE" 2>/dev/null || true)
fi
bar="${bar:-waybar}"

# Notifications: dunst handles them in waybar mode; quickshell has its own
# notification server. Only one daemon can own the D-Bus name, so we hand off.
start_dunst() {
    pgrep -x dunst >/dev/null || (dunst &)
}
stop_dunst() {
    pkill -x dunst 2>/dev/null || true
}

start_waybar() {
    start_dunst
    # Reuse the existing waybar-launcher.sh which sets up rbenv etc.
    if [[ -x "$HOME/.config/waybar/waybar-launcher.sh" ]]; then
        exec "$HOME/.config/waybar/waybar-launcher.sh"
    else
        exec waybar
    fi
}

# Run quickshell under a bounded crash-respawn loop. quickshell-git can
# transiently SIGSEGV (e.g. in its Hyprland IPC toplevel tracking), so respawn
# to self-heal — but stop on a deliberate switch and bail out to waybar if it
# crash-loops, so the user is never left bar-less.
start_quickshell() {
    if ! command -v qs >/dev/null && ! command -v quickshell >/dev/null; then
        notify-send -u critical "Bar launcher" "quickshell not installed — falling back to waybar" 2>/dev/null || true
        start_waybar
    fi
    stop_dunst  # quickshell's NotificationServer takes over the D-Bus name

    local cmd; cmd=$(command -v qs || command -v quickshell)
    local restarts=0 window_start
    window_start=$(date +%s)

    while :; do
        "$cmd"
        local rc=$?

        # Deliberate switch? bar-switch writes the new preference before killing
        # us, so a preference that's no longer quickshell means "stop" — the
        # switch already spawned a fresh launcher for the other bar.
        local pref
        pref=$(cat "$PREF_FILE" 2>/dev/null || echo waybar)
        [[ "$pref" != "quickshell" && "$pref" != "qs" ]] && exit 0

        # Clean exit (not a crash, not a switch) — treat as intentional.
        [[ $rc -eq 0 ]] && exit 0

        # Crash. Count restarts in a rolling 60s window; reset when it's been
        # stable for a while.
        local now; now=$(date +%s)
        (( now - window_start > 60 )) && { restarts=0; window_start=$now; }
        restarts=$((restarts + 1))

        if (( restarts > 5 )); then
            notify-send -u critical "Bar launcher" \
                "quickshell crashed repeatedly — falling back to waybar" 2>/dev/null || true
            echo waybar > "$PREF_FILE"
            start_waybar
        fi

        notify-send "Bar launcher" "quickshell crashed — restarting ($restarts)" 2>/dev/null || true
        sleep 1   # brief backoff before respawn
    done
}

case "$bar" in
    quickshell|qs) start_quickshell ;;
    waybar|*)      start_waybar ;;
esac
