#!/bin/bash

# Apply lupus waybar customizations on top of Omarchy's managed config.
# Safe to re-run - checks before modifying. Designed to be called:
#   - By the Ansible playbook during setup
#   - By the Omarchy post-update hook after migrations
#   - Manually after an omarchy-refresh-waybar

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
export LUPUS_WAYBAR="$DOTFILES_DIR/lupus/waybar"
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOGFILE="$HOME/.local/state/lupus-waybar.log"
mkdir -p "$(dirname "$LOGFILE")"

# Surface a problem loudly: log it and (if a session is available) notify.
warn_loudly() {
  local msg="$1"
  echo "  WARNING: $msg"
  echo "$(date '+%F %T') $msg" >> "$LOGFILE"
  command -v notify-send >/dev/null 2>&1 && notify-send -u critical "Waybar customization" "$msg" || true
}

echo "Applying lupus waybar customizations..."

# --- 0. Check if Omarchy waybar config exists yet ---
if [ ! -f "$WAYBAR_CONFIG" ]; then
  echo "  Waybar config not found at $WAYBAR_CONFIG"
  echo "  Omarchy may not have set up waybar yet (reboot/session restart needed)."
  echo "  Skipping config patching - the post-update hook will re-run this later."
  # Still link status scripts so they're ready when waybar starts
  mkdir -p "$HOME/.local/bin"
  ln -sf "$LUPUS_WAYBAR/gpu-status.sh" "$HOME/.local/bin/gpu-status"
  ln -sf "$LUPUS_WAYBAR/fan-status.sh" "$HOME/.local/bin/fan-status"
  echo "  Linked gpu-status and fan-status to ~/.local/bin/"
  exit 0
fi

# --- 1. Symlink gpu-status script to PATH ---
if [ ! -L "$HOME/.local/bin/gpu-status" ] || [ "$(readlink -f "$HOME/.local/bin/gpu-status")" != "$LUPUS_WAYBAR/gpu-status.sh" ]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$LUPUS_WAYBAR/gpu-status.sh" "$HOME/.local/bin/gpu-status"
  echo "  Linked gpu-status to ~/.local/bin/"
fi

# --- 1a. Symlink fan-status script to PATH ---
if [ ! -L "$HOME/.local/bin/fan-status" ] || [ "$(readlink -f "$HOME/.local/bin/fan-status")" != "$LUPUS_WAYBAR/fan-status.sh" ]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$LUPUS_WAYBAR/fan-status.sh" "$HOME/.local/bin/fan-status"
  echo "  Linked fan-status to ~/.local/bin/"
fi

# --- 2. Patch waybar config.jsonc using Python (safe JSON manipulation) ---
# This avoids fragile sed patterns that can corrupt JSON by matching
# module definition keys instead of array entries.
# Exit status 3 means an anchor was missing and a module had to be appended
# as a fallback (the caller surfaces this loudly).
PATCH_STATUS=0
python3 << 'PYEOF' || PATCH_STATUS=$?
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

# Add include directive (and clean up any broken paths from previous runs)
include_path = lupus_waybar + "/custom-modules.jsonc"
if "include" not in config:
    # Insert include as first key by rebuilding dict
    new_config = {"include": [include_path]}
    new_config.update(config)
    config = new_config
    changed = True
    print("  Added include directive for custom-modules.jsonc")
else:
    # Remove any broken include paths (e.g. "/custom-modules.jsonc" from unexported var bug)
    clean_includes = [p for p in config["include"] if p == include_path or not p.endswith("/custom-modules.jsonc")]
    if len(clean_includes) != len(config["include"]):
        config["include"] = clean_includes
        changed = True
        print("  Cleaned broken include paths")
    if include_path not in config["include"]:
        config["include"].append(include_path)
        changed = True
        print("  Added include path to existing include array")
    else:
        print("  Include directive already present")

# Modify modules-right
modules_right = config.get("modules-right", [])
warnings = []

def ensure_module(name, anchor, offset):
    """Place `name` relative to `anchor` (offset 0 = before, 1 = after).
    If the anchor is missing (Omarchy reshuffled its default bar), append at
    the end so the module is never silently dropped, and record a warning so
    the caller can flag that the anchors need updating."""
    global changed
    if name in modules_right:
        print(f"  {name} already in modules-right")
        return
    changed = True
    try:
        idx = modules_right.index(anchor)
        modules_right.insert(idx + offset, name)
        print(f"  Added {name} to modules-right (near {anchor})")
    except ValueError:
        modules_right.append(name)
        warnings.append(f"anchor '{anchor}' missing for {name}; appended at end as fallback")
        print(f"  WARNING: anchor '{anchor}' missing for {name}; appended at end")

ensure_module("custom/caffeine", "group/tray-expander", 1)
ensure_module("custom/gpu", "cpu", 0)
ensure_module("custom/fan", "custom/gpu", 1)  # depends on gpu, inserted above
ensure_module("memory", "cpu", 1)

config["modules-right"] = modules_right

if changed:
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("  Config written successfully")
else:
    print("  No config changes needed")

# Signal the shell wrapper that anchors drifted so it can alert loudly.
if warnings:
    sys.exit(3)
PYEOF

# If patching had to fall back (anchors changed in Omarchy's default bar),
# the modules are still present but possibly mis-ordered — make it visible.
if [ "$PATCH_STATUS" -eq 3 ]; then
  warn_loudly "Omarchy's default waybar layout changed; lupus modules were appended as a fallback. Update the anchors in apply-customizations.sh."
elif [ "$PATCH_STATUS" -ne 0 ]; then
  warn_loudly "waybar config patching failed (status $PATCH_STATUS) — see $WAYBAR_CONFIG"
fi

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
  waybar >/dev/null 2>&1 &
  disown
  echo "  Waybar restarted"
fi

echo "Done."
