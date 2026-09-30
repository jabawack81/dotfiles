#!/bin/bash

# Select the appropriate fastfetch config based on hostname, so each machine
# can have its own logo and layout.
#
# On personal machines ~/.config/fastfetch is the <hostname>/fastfetch
# directory from the dotfiles, so plain `fastfetch` already picks up the
# machine config; only work machines need an explicit --config here.

# uname -n rather than hostname(1): the latter comes from inetutils, which
# is not installed by default on Arch.
HOSTNAME=$(uname -n | tr '[:upper:]' '[:lower:]')
CONFIG_DIR="$HOME/.config/fastfetch"
PRIVATE_LOGOS="$HOME/dotfiles/private-config/logos"

# Check if we're in tmux and if image logos exist
IN_TMUX=""
if [ -n "$TMUX" ]; then
    IN_TMUX="yes"
fi

# Determine if this is a personal machine (kyrios, shinkiro, or barbatos) or work machine
IS_PERSONAL_MACHINE=false
if [ "$HOSTNAME" = "kyrios" ] || [ "$HOSTNAME" = "shinkiro" ] || [ "$HOSTNAME" = "barbatos" ]; then
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