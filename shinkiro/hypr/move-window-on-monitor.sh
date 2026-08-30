#!/bin/bash
# Move the active window to the next/prev workspace on the same monitor.
# Odd workspaces → left monitor, even workspaces → right monitor.
# Works for any workspace number (not limited to 1-10).
set -euo pipefail

DIRECTION=${1:?Usage: $0 next|prev}
CURRENT=$(hyprctl activeworkspace -j | jq '.id')

# Detect monitors by physical position (leftmost = odd, rightmost = even)
LEFT_MON=$(hyprctl monitors -j | jq -r 'sort_by(.x) | .[0].name')
RIGHT_MON=$(hyprctl monitors -j | jq -r 'sort_by(.x) | .[1].name')

if [ "$DIRECTION" = "next" ]; then
    TARGET=$((CURRENT + 2))
else
    TARGET=$((CURRENT - 2))
    # Don't go below the first workspace per monitor (1 for odd, 2 for even)
    if [ "$TARGET" -lt 1 ]; then
        exit 0
    fi
fi

# Assign to correct monitor based on odd/even
if [ $((TARGET % 2)) -eq 1 ]; then
    MON="$LEFT_MON"
else
    MON="$RIGHT_MON"
fi

# Hyprland 0.56 Lua configs changed `hyprctl dispatch` to evaluate Lua rather
# than legacy dispatcher names, so `hyprctl dispatch workspace 3` is a syntax
# error now. These calls use the Lua API instead.
hyprctl dispatch "hl.dsp.window.move({ workspace = $TARGET })" >/dev/null
hyprctl dispatch "hl.dsp.workspace.move({ workspace = $TARGET, monitor = '$MON' })" >/dev/null
