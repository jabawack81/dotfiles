#!/bin/bash
# Waybar module: caffeine/power state
# States: normal, caffeine (stay awake), remote (PC on, no hibernate), hibernate

STATE_FILE="${XDG_RUNTIME_DIR:-$HOME/.cache}/caffeine-state"
state=$(cat "$STATE_FILE" 2>/dev/null || echo "normal")

# Sync: if state says caffeine (no hypridle) but hypridle is running, reset
if [[ "$state" == "caffeine" ]] && pgrep -x hypridle > /dev/null; then
    state="normal"
    echo "normal" > "$STATE_FILE"
fi

case "$state" in
    caffeine)
        echo '{"text": "󰅶", "tooltip": "Caffeine\nScreen stays awake\n\nLeft click → Remote\nRight click → Normal", "class": "caffeine"}' ;;
    remote)
        echo '{"text": "󰢹", "tooltip": "Remote mode\nLocks in 90s, no hibernate\nPC stays on for remote access\n\nLeft click → Hibernate\nRight click → Normal", "class": "remote"}' ;;
    hibernate)
        echo '{"text": "󰤄", "tooltip": "Hibernate mode\nLocks in 90s, hibernates in 5min\n\nLeft click → Normal\nRight click → Normal", "class": "hibernate"}' ;;
    *)
        echo '{"text": "󰒲", "tooltip": "Normal\nIdle: 5min screen off, 10min lock, 30min suspend\n\nLeft click → Caffeine\nRight click → Normal", "class": "normal"}' ;;
esac
