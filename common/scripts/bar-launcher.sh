#!/bin/bash
# Launch the user's preferred status bar (waybar or quickshell).
# Preference is read from $BAR env var, then ~/.cache/preferred-bar.
# Falls back to waybar if anything goes wrong — waybar is the safe default.
#
# Used by Hyprland exec-once; also called by bar-switch.sh at runtime.

set -u

PREF_FILE="$HOME/.cache/preferred-bar"

# 1. Explicit env var wins (set by greetd session entries)
# 2. Otherwise read the saved preference
# 3. Otherwise default to waybar
bar="${BAR:-}"
if [[ -z "$bar" && -f "$PREF_FILE" ]]; then
    bar=$(cat "$PREF_FILE" 2>/dev/null || true)
fi
bar="${bar:-waybar}"

start_waybar() {
    # Reuse the existing waybar-launcher.sh which sets up rbenv etc.
    if [[ -x "$HOME/.config/waybar/waybar-launcher.sh" ]]; then
        exec "$HOME/.config/waybar/waybar-launcher.sh"
    else
        exec waybar
    fi
}

start_quickshell() {
    if ! command -v qs >/dev/null && ! command -v quickshell >/dev/null; then
        notify-send -u critical "Bar launcher" "quickshell not installed — falling back to waybar" 2>/dev/null || true
        start_waybar
    fi
    local cmd
    cmd=$(command -v qs || command -v quickshell)
    exec "$cmd"
}

case "$bar" in
    quickshell|qs) start_quickshell ;;
    waybar|*)      start_waybar ;;
esac
