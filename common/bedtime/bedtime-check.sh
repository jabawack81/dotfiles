#!/bin/bash
# Bedtime reminder script - gets progressively more annoying

HOUR=$(date +%-H)  # %-H gives hour without leading zero
MINUTE=$(date +%-M)
DAY=$(date +%u) # 1=Monday, 7=Sunday

# Check if it's a school night (Sunday-Thursday nights)
# Note: We check the current day, but we care about the night
# So Monday (1) night through Thursday (4) night, and Sunday (7) night
# We exclude Friday (5) and Saturday (6) nights
is_schoolnight() {
    # Sunday (7) through Thursday (4) - school nights
    # Exclude Friday (5) and Saturday (6)
    [ $DAY -ne 5 ] && [ $DAY -ne 6 ]
}

# Only run on school nights
if ! is_schoolnight; then
    exit 0
fi

# Calculate how late it is
get_severity() {
    if [ $HOUR -eq 23 ] && [ $MINUTE -lt 30 ]; then
        echo "1"  # 23:00-23:29 - Gentle reminder
    elif [ $HOUR -eq 23 ] && [ $MINUTE -ge 30 ]; then
        echo "2"  # 23:30-23:59 - Getting serious
    elif [ $HOUR -eq 0 ] && [ $MINUTE -lt 30 ]; then
        echo "3"  # 00:00-00:29 - Very serious
    elif [ $HOUR -eq 0 ] && [ $MINUTE -ge 30 ]; then
        echo "4"  # 00:30-00:59 - Critical
    elif [ $HOUR -ge 1 ] && [ $HOUR -lt 6 ]; then
        echo "5"  # 01:00-05:59 - DEFCON 1
    else
        echo "0"  # Not bedtime
    fi
}

SEVERITY=$(get_severity)

case $SEVERITY in
    1)
        notify-send -t 10000 "Bedtime Reminder 🌙" "Hey, it's 11 PM! Time to start winding down for bed."
        ;;
    2)
        notify-send -u critical -t 15000 "GO TO BED! 😤" "It's past 11:30 PM! You said you wanted better sleep habits!"
        # Also play a sound if available
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
        ;;
    3)
        notify-send -u critical -t 20000 "SERIOUSLY, BED NOW! 😡" "It's past midnight! Your future self will hate you!"
        # Flash the screen using Hyprland
        hyprctl dispatch exec "sh -c 'for i in {1..3}; do hyprctl keyword decoration:dim_inactive 1; sleep 0.2; hyprctl keyword decoration:dim_inactive 0; sleep 0.2; done'" 2>/dev/null
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
        ;;
    4)
        notify-send -u critical -t 30000 "FINAL WARNING! 🚨" "It's past 12:30 AM! I'm about to get REALLY annoying!"
        # More aggressive screen flash
        hyprctl dispatch exec "sh -c 'for i in {1..5}; do hyprctl keyword decoration:dim_inactive 1; sleep 0.1; hyprctl keyword decoration:dim_inactive 0; sleep 0.1; done'" 2>/dev/null
        # Play sound multiple times
        for i in {1..3}; do
            paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
            sleep 1
        done
        ;;
    5)
        # DEFCON 1 - Maximum annoyance
        notify-send -u critical -t 60000 "YOU'RE STILL AWAKE?! 💀" "It's $(date +%H:%M)! This is self-sabotage at this point!"
        
        # Create a floating window with a bedtime message
        echo "GO TO BED NOW!" | fuzzel --dmenu --prompt "IT'S $(date +%H:%M) - TIME FOR BED!" &
        
        # Flash screen aggressively
        hyprctl dispatch exec "sh -c 'for i in {1..10}; do hyprctl keyword decoration:dim_inactive 1; sleep 0.05; hyprctl keyword decoration:dim_inactive 0; sleep 0.05; done'" 2>/dev/null
        
        # Play alarm sound on loop for 10 seconds
        timeout 10s bash -c 'while true; do paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true; done'
        ;;
esac