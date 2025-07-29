#!/bin/bash
# Toggle EWW dashboard visibility

if pgrep -x eww > /dev/null; then
    ~/.local/bin/eww close-all
    pkill -x eww
else
    ~/.config/eww/eww-launcher.sh &
fi