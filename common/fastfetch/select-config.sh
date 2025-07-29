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

# Only the work machine (paolofabbri) should use a custom logo
if [ "$HOSTNAME" = "paolofabbri" ]; then
    if [ -f "$CONFIG_DIR/config-${HOSTNAME}.jsonc" ]; then
        # Use machine-specific config
        exec fastfetch --config "$CONFIG_DIR/config-${HOSTNAME}.jsonc" "$@"
    elif [ -f "$PRIVATE_LOGOS/${HOSTNAME}_logo_raw.txt" ]; then
        # Use machine-specific logo with default config
        exec fastfetch --logo-type file-raw --logo "$PRIVATE_LOGOS/${HOSTNAME}_logo_raw.txt" "$@"
    fi
fi

# All other machines (including kyrios and shinkiro) use OS logo
exec fastfetch "$@"