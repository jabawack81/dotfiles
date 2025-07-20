#!/bin/bash
# Power menu script for waybar using wofi

# Define options
options="Lock\nLogout\nSuspend\nReboot\nShutdown\nCancel"

# Show menu and get selection
selected=$(echo -e "$options" | wofi --dmenu --prompt "Power Menu" --cache-file=/dev/null)

# Execute based on selection
case "$selected" in
    "Lock")
        swaylock || hyprlock || i3lock
        ;;
    "Logout")
        hyprctl dispatch exit || swaymsg exit
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
    *)
        # Cancel or escape
        exit 0
        ;;
esac