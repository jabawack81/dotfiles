#!/bin/bash

# Script to select the appropriate fastfetch config based on hostname
# This allows for machine-specific logos and configurations

HOSTNAME=$(hostname | tr '[:upper:]' '[:lower:]')
CONFIG_DIR="$HOME/.config/fastfetch"
PRIVATE_LOGOS="$HOME/dotfiles/private-config/logos"

# Check if we're in tmux and if image logos exist
IN_TMUX=""
if [ -n "$TMUX" ]; then
    IN_TMUX="yes"
fi

# Determine if this is a personal machine (kyrios or shinkiro) or work machine
IS_PERSONAL_MACHINE=false
if [ "$HOSTNAME" = "kyrios" ] || [ "$HOSTNAME" = "shinkiro" ]; then
    IS_PERSONAL_MACHINE=true
fi

# Only work machines should use a custom logo from private config
if [ "$IS_PERSONAL_MACHINE" = false ]; then
    if [ -f "$CONFIG_DIR/config-work.jsonc" ]; then
        # Use work machine config with company logo
        exec fastfetch --config "$CONFIG_DIR/config-work.jsonc" "$@"
    elif [ -f "$PRIVATE_LOGOS/work_logo_raw.txt" ]; then
        # Use work logo with default config
        exec fastfetch --logo-type file-raw --logo "$PRIVATE_LOGOS/work_logo_raw.txt" "$@"
    fi
fi

# All other machines (kyrios and shinkiro) use OS logo
exec fastfetch "$@"