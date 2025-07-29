#!/bin/bash

# Script to test and display all fastfetch logos with proper colors

echo "=== Fastfetch Logo Gallery ==="
echo ""

# Function to display a logo with its name
display_logo() {
    local logo_name="$1"
    local logo_file="$2"
    
    if [ -f "$logo_file" ]; then
        echo "┌─────────────────────────────────────────┐"
        echo "│ $logo_name"
        echo "└─────────────────────────────────────────┘"
        # Just cat the file - it now has proper escape sequences
        cat "$logo_file"
        echo ""
        echo ""
    else
        echo "⚠️  $logo_name logo not found at: $logo_file"
        echo ""
    fi
}

# Check if private-config exists
if [ ! -d "$HOME/dotfiles/private-config/logos" ]; then
    echo "❌ Private config logos directory not found!"
    echo "   Expected at: $HOME/dotfiles/private-config/logos"
    echo ""
    echo "Make sure you have initialized the private config submodule:"
    echo "  cd ~/dotfiles"
    echo "  git submodule update --init --recursive"
    exit 1
fi

# Display all logos
display_logo "Work Machine" "$HOME/dotfiles/private-config/logos/work_logo_raw.txt"
display_logo "Kyrios (Personal Laptop)" "$HOME/dotfiles/private-config/logos/kyrios_logo_raw.txt"
display_logo "Shinkiro (Personal Desktop)" "$HOME/dotfiles/private-config/logos/shinkiro_logo_raw.txt"
display_logo "Default (Unknown Machines)" "$HOME/dotfiles/private-config/logos/default_logo_raw.txt"

# Show current machine info
echo "┌─────────────────────────────────────────┐"
echo "│ Current Machine Info"
echo "└─────────────────────────────────────────┘"
echo "Hostname: $(hostname)"
echo "Lowercase: $(hostname | tr '[:upper:]' '[:lower:]')"
echo ""

# Test which logo would be used
HOSTNAME=$(hostname | tr '[:upper:]' '[:lower:]')
echo "This machine would use:"
if [ -f "$HOME/dotfiles/private-config/logos/${HOSTNAME}_logo_raw.txt" ]; then
    echo "✅ Machine-specific logo: ${HOSTNAME}_logo_raw.txt"
elif [ -f "$HOME/dotfiles/private-config/logos/default_logo_raw.txt" ]; then
    echo "📦 Default logo: default_logo_raw.txt"
else
    echo "❌ No logo found!"
fi