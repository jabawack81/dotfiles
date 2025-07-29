#!/usr/bin/env bash
# Wrapper script to run Ruby script with rbenv
source "$HOME/.zshrc" 2>/dev/null || true
exec ruby "$HOME/.config/waybar_common/network-status.rb" "$@"