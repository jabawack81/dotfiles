#!/bin/bash
# Waybar module: night light status (hyprsunset)

if pgrep -x hyprsunset > /dev/null; then
    echo '{"text": "󰃠", "tooltip": "Night Light: ON\nClick to disable", "class": "on"}'
else
    echo '{"text": "󰃜", "tooltip": "Night Light: OFF\nClick to enable", "class": "off"}'
fi
