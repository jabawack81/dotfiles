#!/bin/bash

# Test script to verify install-configs.sh logic
# This script simulates what would happen without actually making changes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTNAME=$(cat /etc/hostname 2>/dev/null || echo "unknown")

echo "=== Test Installation Script ==="
echo "Hostname: $HOSTNAME"
echo "Script directory: $SCRIPT_DIR"
echo

# Check if hostname config exists
if [[ -d "$SCRIPT_DIR/$HOSTNAME" ]]; then
    echo "✓ Configuration directory found: $SCRIPT_DIR/$HOSTNAME"
    CONFIG_DIR="$SCRIPT_DIR/$HOSTNAME"
else
    echo "✗ No configuration found for hostname '$HOSTNAME'"
    echo "Available configurations:"
    for dir in "$SCRIPT_DIR"/*; do
        if [[ -d "$dir" && "$(basename "$dir")" != "thunar" ]]; then
            echo "  - $(basename "$dir")"
        fi
    done
    exit 1
fi

echo

# Check what would be installed
echo "=== Configuration Check ==="

# Thunar
echo "Thunar theme:"
if [[ -d "$CONFIG_DIR/thunar" ]]; then
    echo "  ✓ Thunar directory found"
    [[ -f "$CONFIG_DIR/thunar/gtk.css" ]] && echo "  ✓ GTK3 theme available"
    [[ -f "$CONFIG_DIR/thunar/gtkrc-2.0" ]] && echo "  ✓ GTK2 theme available"
else
    echo "  ✗ Thunar directory not found"
fi

# Hyprland
echo "Hyprland config:"
if [[ -d "$CONFIG_DIR/hypr" ]]; then
    echo "  ✓ Hypr directory found"
    [[ -f "$CONFIG_DIR/hypr/hyprland.conf" ]] && echo "  ✓ Hyprland config available"
    [[ -f "$CONFIG_DIR/hypr/hyprlock.conf" ]] && echo "  ✓ Hyprlock config available"
    [[ -d "$CONFIG_DIR/hypr/Fonts" ]] && echo "  ✓ Fonts directory available"
else
    echo "  ✗ Hypr directory not found"
fi

# Waybar
echo "Waybar config:"
if [[ -d "$CONFIG_DIR/waybar" ]]; then
    echo "  ✓ Waybar directory found"
    [[ -f "$CONFIG_DIR/waybar/config" ]] && echo "  ✓ Waybar config available"
    [[ -f "$CONFIG_DIR/waybar/style.css" ]] && echo "  ✓ Waybar style available"
else
    echo "  ✗ Waybar directory not found"
fi

echo
echo "=== Test Complete ==="
echo "Run './install-configs.sh' to actually install the configurations"