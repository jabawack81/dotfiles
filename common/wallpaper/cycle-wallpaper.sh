#!/usr/bin/env bash
# cycle-wallpaper.sh — pick a random wallpaper, apply it to every monitor
# (mirrored), and point ~/.cache/current-wallpaper at it so hyprlock stays
# aligned with whatever the desktop is showing.

set -euo pipefail

WALL_DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
CURRENT_LINK="$HOME/.cache/current-wallpaper"

shopt -s nullglob nocaseglob
mapfile -t images < <(printf '%s\n' "$WALL_DIR"/*.{png,jpg,jpeg,webp})
shopt -u nullglob nocaseglob

if (( ${#images[@]} == 0 )); then
    echo "no wallpapers found in $WALL_DIR" >&2
    exit 1
fi

# Avoid immediate repeats when possible.
current_real=""
[[ -L "$CURRENT_LINK" ]] && current_real="$(readlink -f -- "$CURRENT_LINK" 2>/dev/null || true)"

pick=""
if (( ${#images[@]} > 1 && ${#current_real} > 0 )); then
    for _ in 1 2 3 4 5; do
        candidate="${images[RANDOM % ${#images[@]}]}"
        if [[ "$(readlink -f -- "$candidate")" != "$current_real" ]]; then
            pick="$candidate"
            break
        fi
    done
fi
[[ -z "$pick" ]] && pick="${images[RANDOM % ${#images[@]}]}"

# Wait for hyprpaper's IPC socket (useful on login when exec-once races).
sock="${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.hyprpaper.sock"
for _ in $(seq 1 40); do
    [[ -S "$sock" ]] && break
    sleep 0.25
done
if [[ ! -S "$sock" ]]; then
    echo "hyprpaper socket never appeared at $sock — is hyprpaper running?" >&2
    exit 1
fi

# hyprpaper 0.8+ text IPC exposes only `wallpaper` — it auto-preloads.
while read -r mon; do
    [[ -z "$mon" ]] && continue
    hyprctl hyprpaper wallpaper "$mon,$pick" >/dev/null
done < <(hyprctl monitors -j | jq -r '.[].name')

# Atomic symlink update so hyprlock always sees a valid target.
mkdir -p "$(dirname "$CURRENT_LINK")"
ln -sfn -- "$pick" "$CURRENT_LINK.tmp"
mv -Tf -- "$CURRENT_LINK.tmp" "$CURRENT_LINK"

echo "wallpaper → $pick"
