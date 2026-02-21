#!/bin/bash
# Waybar module: caffeine status (hypridle toggle)
# Caffeine ON = hypridle killed = screen stays awake

if pgrep -x hypridle > /dev/null; then
    echo '{"text": "󰒲", "tooltip": "Caffeine: OFF\nScreen will idle normally\nClick to keep screen awake", "class": "off"}'
else
    echo '{"text": "󰅶", "tooltip": "Caffeine: ON\nScreen will stay awake\nClick to restore idle", "class": "on"}'
fi
