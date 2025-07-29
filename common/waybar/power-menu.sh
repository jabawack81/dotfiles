#!/bin/bash
# Power menu script for waybar using fuzzel

# Define options
options="Lock\nLogout\nSuspend\nReboot\nShutdown\nCancel"

# Show menu and get selection
selected=$(echo -e "$options" | fuzzel --dmenu --prompt "Power Menu: ")

# Execute based on selection
case "$selected" in
    "Lock")
        hyprlock
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