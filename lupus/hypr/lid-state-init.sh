#!/bin/bash
# Apply lid state on Hyprland startup.
# Lid switch bindings only fire on transitions, so if the system boots with
# the lid closed, eDP-1 stays enabled and the fingerprint daemon stays running.
# This script reads the current lid state and applies the correct config.

set -euo pipefail

LID_STATE_FILE="/proc/acpi/button/lid/LID/state"

# Wait briefly for Hyprland to be ready to accept ipc commands
sleep 2

if [ ! -r "$LID_STATE_FILE" ]; then
  exit 0
fi

if grep -q "closed" "$LID_STATE_FILE"; then
  hyprctl keyword monitor "eDP-1, disable"
  sudo -n systemctl stop open-fprintd.service 2>/dev/null || true
else
  hyprctl keyword monitor "eDP-1, preferred, auto, 1"
  sudo -n systemctl start open-fprintd.service 2>/dev/null || true
fi
