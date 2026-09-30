#!/bin/bash
# Lid switch handler for barbatos (ThinkPad T470p).
#
#   lid.sh closed   panel off, fingerprint daemon stopped
#   lid.sh open     panel back on, fingerprint daemon started
#   lid.sh init     apply whichever state the lid is in right now
#
# The switch binds in hyprland.lua only fire on transitions, so `init` runs
# once at Hyprland startup to cover booting with the lid already closed.
#
# Stopping open-fprintd needs the NOPASSWD sudoers drop-in that
# tasks/barbatos.yml installs; `sudo -n` fails quietly without it.

set -euo pipefail

LID_STATE_FILE="/proc/acpi/button/lid/LID/state"

# Number of enabled monitors (hyprctl monitors omits disabled ones).
enabled_monitors() {
  hyprctl monitors 2>/dev/null | grep -c '^Monitor' || echo 0
}

lid_closed() {
  # Only blank the panel when something else can still show a desktop.
  # Disabling the sole output leaves Hyprland with zero monitors: windows get
  # shuffled onto a fallback head and layer surfaces (the bar) are destroyed,
  # and waybar does not always recreate them when the output comes back.
  if [ "$(enabled_monitors)" -gt 1 ]; then
    hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })' >/dev/null
  fi
  sudo -n systemctl stop open-fprintd.service 2>/dev/null || true
}

lid_open() {
  hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })' >/dev/null
  sudo -n systemctl start open-fprintd.service 2>/dev/null || true
}

case "${1:-}" in
  closed) lid_closed ;;
  open)   lid_open ;;
  init)
    # Give Hyprland a moment to accept IPC after exec-once
    sleep 2
    [ -r "$LID_STATE_FILE" ] || exit 0
    if grep -q closed "$LID_STATE_FILE"; then
      lid_closed
    else
      lid_open
    fi
    ;;
  *)
    echo "usage: $0 {closed|open|init}" >&2
    exit 2
    ;;
esac
