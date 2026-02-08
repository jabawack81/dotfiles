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

# --- 2. Patch waybar config.jsonc using Python (safe JSON manipulation) ---
# This avoids fragile sed patterns that can corrupt JSON by matching
# module definition keys instead of array entries.
python3 << 'PYEOF'
import json
import sys
import os

config_path = os.path.expanduser("~/.config/waybar/config.jsonc")
lupus_waybar = os.environ.get("LUPUS_WAYBAR", "")

# Read and strip any JSONC comments (// style) before parsing
with open(config_path, "r") as f:
    lines = f.readlines()

# Strip single-line comments for parsing (preserve original for non-JSON lines)
clean_lines = []
for line in lines:
    stripped = line.lstrip()
    if stripped.startswith("//"):
        continue
    clean_lines.append(line)

config = json.loads("".join(clean_lines))
changed = False

# Add include directive
include_path = lupus_waybar + "/custom-modules.jsonc"
if "include" not in config:
    # Insert include as first key by rebuilding dict
    new_config = {"include": [include_path]}
    new_config.update(config)
    config = new_config
    changed = True
    print("  Added include directive for custom-modules.jsonc")
elif include_path not in config["include"]:
    config["include"].append(include_path)
    changed = True
    print("  Added include path to existing include array")
else:
    print("  Include directive already present")

# Modify modules-right
modules_right = config.get("modules-right", [])

# Add custom/caffeine after group/tray-expander
if "custom/caffeine" not in modules_right:
    try:
        idx = modules_right.index("group/tray-expander")
        modules_right.insert(idx + 1, "custom/caffeine")
        changed = True
        print("  Added custom/caffeine to modules-right")
    except ValueError:
        print("  WARNING: group/tray-expander not found in modules-right")
else:
    print("  custom/caffeine already in modules-right")

# Add custom/gpu before cpu
if "custom/gpu" not in modules_right:
    try:
        idx = modules_right.index("cpu")
        modules_right.insert(idx, "custom/gpu")
        changed = True
        print("  Added custom/gpu to modules-right")
    except ValueError:
        print("  WARNING: cpu not found in modules-right")
else:
    print("  custom/gpu already in modules-right")

# Add memory after cpu
if "memory" not in modules_right:
    try:
        idx = modules_right.index("cpu")
        modules_right.insert(idx + 1, "memory")
        changed = True
        print("  Added memory to modules-right")
    except ValueError:
        print("  WARNING: cpu not found in modules-right")
else:
    print("  memory already in modules-right")

config["modules-right"] = modules_right

if changed:
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("  Config written successfully")
else:
    print("  No config changes needed")
PYEOF

# --- 3. Add custom CSS import if missing ---
IMPORT_LINE="@import \"$LUPUS_WAYBAR/custom-style.css\";"
if ! grep -q 'custom-style.css' "$WAYBAR_STYLE" 2>/dev/null; then
  echo "" >> "$WAYBAR_STYLE"
  echo "$IMPORT_LINE" >> "$WAYBAR_STYLE"
  echo "  Added custom-style.css import to style.css"
else
  echo "  Custom style import already present"
fi

# --- 4. Restart waybar to apply changes ---
if pgrep -x waybar > /dev/null; then
  killall waybar
  sleep 1
  waybar &
  disown
  echo "  Waybar restarted"
fi

echo "Done."
