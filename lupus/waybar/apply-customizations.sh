#!/bin/bash

# Apply lupus waybar customizations on top of Omarchy's managed config.
# Safe to re-run - checks before modifying. Designed to be called:
#   - By the Ansible playbook during setup
#   - By the Omarchy post-update hook after migrations
#   - Manually after an omarchy-refresh-waybar

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
LUPUS_WAYBAR="$DOTFILES_DIR/lupus/waybar"
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

echo "Applying lupus waybar customizations..."

# --- 1. Symlink gpu-status script to PATH ---
if [ ! -L "$HOME/.local/bin/gpu-status" ] || [ "$(readlink -f "$HOME/.local/bin/gpu-status")" != "$LUPUS_WAYBAR/gpu-status.sh" ]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$LUPUS_WAYBAR/gpu-status.sh" "$HOME/.local/bin/gpu-status"
  echo "  Linked gpu-status to ~/.local/bin/"
fi

# --- 2. Add include directive for custom module definitions ---
if ! grep -q 'custom-modules.jsonc' "$WAYBAR_CONFIG" 2>/dev/null; then
  # Add include as the second line (after the opening brace)
  sed -i '1 a\  "include": ["'"$LUPUS_WAYBAR"'/custom-modules.jsonc"],' "$WAYBAR_CONFIG"
  echo "  Added include directive for custom-modules.jsonc"
else
  echo "  Include directive already present"
fi

# --- 3. Add custom/gpu to modules-right if missing ---
if ! grep -q '"custom/gpu"' "$WAYBAR_CONFIG" 2>/dev/null; then
  # Insert custom/gpu before "cpu" in modules-right
  sed -i 's/"cpu"/"custom\/gpu",\n    "cpu"/' "$WAYBAR_CONFIG"
  echo "  Added custom/gpu to modules-right"
else
  echo "  custom/gpu already in modules-right"
fi

# --- 4. Add custom/caffeine to modules-right if missing ---
if ! grep -q '"custom/caffeine"' "$WAYBAR_CONFIG" 2>/dev/null; then
  # Insert custom/caffeine after group/tray-expander
  sed -i 's/"group\/tray-expander"/"group\/tray-expander",\n    "custom\/caffeine"/' "$WAYBAR_CONFIG"
  echo "  Added custom/caffeine to modules-right"
else
  echo "  custom/caffeine already in modules-right"
fi

# --- 5. Add memory to modules-right if missing ---
if ! grep -q '"memory"' "$WAYBAR_CONFIG" 2>/dev/null; then
  # Insert memory after "cpu"
  sed -i 's/"cpu"/"cpu",\n    "memory"/' "$WAYBAR_CONFIG"
  echo "  Added memory to modules-right"
else
  echo "  memory already in modules-right"
fi

# --- 6. Add custom CSS import if missing ---
IMPORT_LINE="@import \"$LUPUS_WAYBAR/custom-style.css\";"
if ! grep -q 'custom-style.css' "$WAYBAR_STYLE" 2>/dev/null; then
  echo "" >> "$WAYBAR_STYLE"
  echo "$IMPORT_LINE" >> "$WAYBAR_STYLE"
  echo "  Added custom-style.css import to style.css"
else
  echo "  Custom style import already present"
fi

# --- 7. Restart waybar to apply changes ---
if pgrep -x waybar > /dev/null; then
  killall waybar
  sleep 1
  waybar &
  disown
  echo "  Waybar restarted"
fi

echo "Done."
