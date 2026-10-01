#!/bin/bash
# Fire a shell action against whichever bar is currently running.
#
# The keybinds live in common/hypr/common.lua and are the same on every
# machine; only the target changes. Hyprland global shortcuts are registered
# by the running shell, so `global, quickshell:omni` is a no-op under
# caelestia and vice versa — this indirection is what keeps one set of keys
# working across all three bars.
#
# Usage: shell-action.sh <launcher|overview|dnd|brightness-up|brightness-down>
#
# Mappings that are not exact are marked below; caelestia has no workspace
# overview and no DND shortcut, so those open the nearest panel.

set -u

PREF_FILE="$HOME/.cache/preferred-bar"
action="${1:-}"

bar=$(cat "$PREF_FILE" 2>/dev/null || echo waybar)

dispatch_global() {
    # Hyprland's Lua config (0.56+) has `hyprctl dispatch` evaluate its
    # argument as Lua, so the classic `dispatch global <name>` form is a
    # syntax error there, while the plain-text config only understands that
    # classic form. Try the Lua one and fall back, rather than sniffing
    # which config style is loaded.
    case "$(hyprctl dispatch "hl.dsp.global(\"$1\")" 2>/dev/null)" in
        ok*) return 0 ;;
    esac
    hyprctl dispatch global "$1" >/dev/null 2>&1
}

# Brightness is a hardware function and has to keep working even when the
# shell is not up, so fall back to the backlight directly unless caelestia
# is running and has actually registered the shortcut.
brightness() {
    if hyprctl globalshortcuts 2>/dev/null | grep -q "^caelestia:brightness$1"; then
        dispatch_global "caelestia:brightness$1"
    else
        brightnessctl s "$2" >/dev/null 2>&1
    fi
}

case "$bar" in
    caelestia)
        case "$action" in
            launcher) dispatch_global "caelestia:launcher" ;;
            overview) dispatch_global "caelestia:showall" ;;    # no true workspace overview
            dnd)      dispatch_global "caelestia:utilities" ;;  # DND toggle lives in this panel
            # Through caelestia rather than brightnessctl directly: its
            # brightness service reads the backlight only at startup and
            # otherwise tracks its own writes, so an external change moves
            # the hardware without the on-screen display ever knowing.
            # Audio needs no such thing — that comes from pipewire, which
            # reports changes whoever made them.
            brightness-up)   brightness Up "10%+" ;;
            brightness-down) brightness Down "10%-" ;;
            *)        exit 2 ;;
        esac
        ;;
    quickshell|qs)
        case "$action" in
            launcher) dispatch_global "quickshell:omni" ;;
            overview) dispatch_global "quickshell:overview" ;;
            dnd)      dispatch_global "quickshell:dnd" ;;
            brightness-up)   brightnessctl s 10%+ >/dev/null ;;
            brightness-down) brightnessctl s 10%- >/dev/null ;;
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
            brightness-up)   brightnessctl s 10%+ >/dev/null ;;
            brightness-down) brightnessctl s 10%- >/dev/null ;;
            *)        exit 2 ;;
        esac
        ;;
esac

exit 0
