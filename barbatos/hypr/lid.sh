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

lid_closed() {
  hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })' >/dev/null
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
