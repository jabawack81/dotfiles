#!/bin/bash
# Create and switch to a new empty workspace on the currently-focused monitor,
# respecting the odd-left / even-right split. The next free workspace with the
# correct parity is chosen (e.g. on the left monitor with 1 3 5 7 9 11 existing,
# the next is 13, not 12).
set -euo pipefail

# Detect monitors by physical position: leftmost gets odd workspaces, rightmost even.
LEFT_MON=$(hyprctl monitors -j | jq -r 'sort_by(.x) | .[0].name')
RIGHT_MON=$(hyprctl monitors -j | jq -r 'sort_by(.x) | .[1].name')

# Which monitor is currently focused?
FOCUSED_MON=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')

if [ "$FOCUSED_MON" = "$LEFT_MON" ]; then
    PARITY=1   # odd
    TARGET_MON="$LEFT_MON"
else
    PARITY=0   # even
    TARGET_MON="$RIGHT_MON"
fi

# Get all existing workspace IDs as a space-separated list for cheap lookup.
EXISTING=$(hyprctl workspaces -j | jq -r '[.[].id] | join(" ")')

# Walk up starting from the lowest valid id for this parity until we find one
# that doesn't exist yet. Cap at 99 just to avoid runaway loops.
i=$(( PARITY == 1 ? 1 : 2 ))
while [ "$i" -lt 100 ]; do
    if ! grep -qw "$i" <<< "$EXISTING"; then
        break
    fi
    i=$((i + 2))
done

hyprctl dispatch workspace "$i" >/dev/null
hyprctl dispatch moveworkspacetomonitor "$i" "$TARGET_MON" >/dev/null
