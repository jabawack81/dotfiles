#!/bin/bash
# Toggle hyprsunset (blue light filter)

if pgrep -x hyprsunset > /dev/null; then
    pkill -x hyprsunset
else
    hyprctl dispatch exec hyprsunset
fi

sleep 0.5
pkill -RTMIN+8 waybar
