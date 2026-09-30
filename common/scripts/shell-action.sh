#!/bin/bash
# Fire a shell action against whichever bar is currently running.
#
# The keybinds live in common/hypr/common.lua and are the same on every
# machine; only the target changes. Hyprland global shortcuts are registered
# by the running shell, so `global, quickshell:omni` is a no-op under
# caelestia and vice versa — this indirection is what keeps one set of keys
# working across all three bars.
#
# Usage: shell-action.sh <launcher|overview|dnd>
#
# Mappings that are not exact are marked below; caelestia has no workspace
# overview and no DND shortcut, so those open the nearest panel.

set -u

PREF_FILE="$HOME/.cache/preferred-bar"
action="${1:-}"

bar=$(cat "$PREF_FILE" 2>/dev/null || echo waybar)

dispatch_global() {
    hyprctl dispatch global "$1" >/dev/null 2>&1
}

case "$bar" in
    caelestia)
        case "$action" in
            launcher) dispatch_global "caelestia:launcher" ;;
            overview) dispatch_global "caelestia:showall" ;;    # no true workspace overview
            dnd)      dispatch_global "caelestia:utilities" ;;  # DND toggle lives in this panel
            *)        exit 2 ;;
        esac
        ;;
    quickshell|qs)
        case "$action" in
            launcher) dispatch_global "quickshell:omni" ;;
            overview) dispatch_global "quickshell:overview" ;;
            dnd)      dispatch_global "quickshell:dnd" ;;
            *)        exit 2 ;;
        esac
        ;;
    *)
        # waybar has no panels of its own; fall back to the standalone launcher
        # and let the other actions be no-ops rather than errors.
        case "$action" in
            launcher)
                command -v hyprlauncher >/dev/null || exit 0
                setsid hyprlauncher </dev/null >/dev/null 2>&1 &
                disown 2>/dev/null || true
                ;;
            overview|dnd) : ;;
            *)        exit 2 ;;
        esac
        ;;
esac

exit 0
