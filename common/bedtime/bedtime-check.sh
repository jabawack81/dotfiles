#!/bin/bash
# Bedtime reminder script - gets progressively more annoying
# Uses central bedtime-severity.sh for base severity

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get base severity from central script
SEVERITY=$("$SCRIPT_DIR/time-status.sh" severity)
EMOJI=$("$SCRIPT_DIR/time-status.sh" emoji)
MESSAGE=$("$SCRIPT_DIR/time-status.sh" message)

# Exit if weekend or not bedtime
if [ "$SEVERITY" -le 0 ]; then
    exit 0
fi

# Get current minute for fine-grained timing
MINUTE=$(date +%-M)
HOUR=$(date +%-H)

# Calculate detailed severity for notifications
# Based on base severity, add granularity
get_detailed_severity() {
    if [ "$SEVERITY" -eq 1 ]; then
        # 10 PM hour - always gentle
        echo "1"
    elif [ "$SEVERITY" -eq 2 ]; then
        # 11 PM hour
        if [ $MINUTE -lt 30 ]; then
            echo "2"  # 11:00-11:29 - Getting serious
        else
            echo "3"  # 11:30-11:59 - Very serious
        fi
    elif [ "$SEVERITY" -eq 3 ]; then
        # After midnight
        if [ $HOUR -eq 0 ] && [ $MINUTE -lt 30 ]; then
            echo "4"  # 00:00-00:29 - Critical
        elif [ $HOUR -eq 0 ] && [ $MINUTE -ge 30 ]; then
            echo "5"  # 00:30-00:59 - More critical
        else
            echo "6"  # 01:00-05:59 - DEFCON 1
        fi
    fi
}

DETAILED_SEVERITY=$(get_detailed_severity)

case $DETAILED_SEVERITY in
    1)
        # 10 PM - Gentle reminder
        notify-send -t 10000 "Bedtime Reminder $EMOJI" "$MESSAGE"
        ;;
    2)
        # 11:00-11:29 PM - Getting serious
        notify-send -u critical -t 15000 "GO TO BED! $EMOJI" "$MESSAGE"
        # Also play a sound if available
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
        ;;
    3)
        # 11:30-11:59 PM - Very serious
        notify-send -u critical -t 20000 "SERIOUSLY, BED NOW! $EMOJI" "It's past 11:30 PM! You said you wanted better sleep habits!"
        # Flash the screen using Hyprland
        hyprctl dispatch exec "sh -c 'for i in {1..3}; do hyprctl keyword decoration:dim_inactive 1; sleep 0.2; hyprctl keyword decoration:dim_inactive 0; sleep 0.2; done'" 2>/dev/null
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
        ;;
    4)
        # 00:00-00:29 AM - Critical
        notify-send -u critical -t 30000 "FINAL WARNING! $EMOJI" "$MESSAGE"
        # More aggressive screen flash
        hyprctl dispatch exec "sh -c 'for i in {1..5}; do hyprctl keyword decoration:dim_inactive 1; sleep 0.1; hyprctl keyword decoration:dim_inactive 0; sleep 0.1; done'" 2>/dev/null
        # Play sound multiple times
        for i in {1..3}; do
            paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
            sleep 1
        done
        ;;
    5)
        # 00:30-00:59 AM - More critical
        notify-send -u critical -t 45000 "YOU'RE STILL AWAKE?! $EMOJI" "It's $(date +%H:%M)! $MESSAGE"
        # Flash and sound
        hyprctl dispatch exec "sh -c 'for i in {1..7}; do hyprctl keyword decoration:dim_inactive 1; sleep 0.08; hyprctl keyword decoration:dim_inactive 0; sleep 0.08; done'" 2>/dev/null
        for i in {1..5}; do
            paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
            sleep 0.5
        done
        ;;
    6)
        # 01:00-05:59 AM - DEFCON 1 - Maximum annoyance
        notify-send -u critical -t 60000 "YOU'RE STILL AWAKE?! $EMOJI" "It's $(date +%H:%M)! $MESSAGE"
        
        # Create a floating window with a bedtime message
        echo "GO TO BED NOW!" | fuzzel --dmenu --prompt "IT'S $(date +%H:%M) - TIME FOR BED!" &
        
        # Flash screen aggressively
        hyprctl dispatch exec "sh -c 'for i in {1..10}; do hyprctl keyword decoration:dim_inactive 1; sleep 0.05; hyprctl keyword decoration:dim_inactive 0; sleep 0.05; done'" 2>/dev/null
        
        # Play alarm sound on loop for 10 seconds
        timeout 10s bash -c 'while true; do paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true; done'
        ;;
esac