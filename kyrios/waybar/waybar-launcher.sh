#!/bin/bash
# Waybar launcher script with proper environment setup

# Source .bashrc or .zshrc to get full environment
if [ -f "$HOME/.zshrc" ]; then
    # Source zshrc in bash-compatible way
    export SHELL=/bin/zsh
    source "$HOME/.zshrc" 2>/dev/null || true
elif [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Ensure PATH includes common locations for Ruby
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

# If rbenv is installed, initialize it
if [ -d "$HOME/.rbenv" ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

# If rvm is installed, source it
if [ -s "$HOME/.rvm/scripts/rvm" ]; then
    source "$HOME/.rvm/scripts/rvm"
fi

# Launch waybar
exec waybar