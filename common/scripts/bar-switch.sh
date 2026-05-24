#!/bin/bash
# Switch status bar at runtime. Saves preference so it persists across logouts.
# Usage: bar-switch.sh [waybar|quickshell|toggle]

set -u

PREF_FILE="$HOME/.cache/preferred-bar"

current=$(cat "$PREF_FILE" 2>/dev/null || echo "waybar")
target="${1:-toggle}"

if [[ "$target" == "toggle" ]]; then
    case "$current" in
        waybar) target="quickshell" ;;
        *)      target="waybar" ;;
    esac
fi

case "$target" in
    waybar|quickshell|qs) ;;
    *)
        echo "Usage: $(basename "$0") [waybar|quickshell|toggle]" >&2
        exit 1
        ;;
esac

# Save preference
mkdir -p "$(dirname "$PREF_FILE")"
echo "$target" > "$PREF_FILE"

# Kill whatever's currently running
pkill -x waybar 2>/dev/null || true
pkill -x qs 2>/dev/null || true
pkill -x quickshell 2>/dev/null || true

sleep 0.3

# Launch the new one in the background, detached
setsid "$HOME/.config/scripts/bar-launcher.sh" >/dev/null 2>&1 &
disown 2>/dev/null || true

notify-send "Bar switched" "Now running: $target" 2>/dev/null || true
