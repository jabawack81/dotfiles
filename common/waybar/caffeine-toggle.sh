#!/bin/bash
# Toggle hypridle (idle management)
# Kill = caffeine ON (screen stays awake)
# Start = caffeine OFF (normal idle behavior)

if pgrep -x hypridle > /dev/null; then
    pkill -x hypridle
else
    hyprctl dispatch exec hypridle
fi

sleep 0.5
pkill -RTMIN+9 waybar
