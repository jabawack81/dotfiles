#!/bin/bash
# Launcher script with fallback options

# Try wofi first with proper error handling
if command -v wofi &> /dev/null; then
    # Set GTK theme to avoid theme parsing errors
    export GTK_THEME=Adwaita:dark
    
    # Try to launch wofi with explicit parameters
    wofi --show drun --width 800 --height 600 --lines 20 --columns 1 2>/tmp/wofi-error.log
    
    # Check if wofi failed
    if [ $? -ne 0 ]; then
        # Log the error
        echo "Wofi failed at $(date)" >> /tmp/wofi-error.log
        
        # Try with minimal config
        wofi --show drun --no-actions --width 800 --height 600 2>>/tmp/wofi-error.log
    fi
else
    # Fallback to dmenu_run if available
    if command -v dmenu_run &> /dev/null; then
        dmenu_run
    else
        notify-send "Launcher Error" "No launcher available. Please install wofi or dmenu."
    fi
fi