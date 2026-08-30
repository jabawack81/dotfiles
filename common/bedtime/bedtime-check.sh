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
# Flash the screen by pulsing inactive-window dimming.
#
# Hyprland 0.56 Lua configs reject `hyprctl keyword` outright ("keyword can't
# work with non-legacy parsers"), and `hyprctl dispatch` now evaluates Lua, so
# the old `dispatch exec "... hyprctl keyword ..."` form fails twice over. This
# uses `hyprctl eval` with the Lua config API and backgrounds the loop directly
# instead of asking the compositor to spawn a shell for us.
flash_screen() {
    local times=$1 delay=$2
    (
        for _ in $(seq "$times"); do
            hyprctl eval 'hl.config({ decoration = { dim_inactive = true } })'  >/dev/null 2>&1
            sleep "$delay"
            hyprctl eval 'hl.config({ decoration = { dim_inactive = false } })' >/dev/null 2>&1
            sleep "$delay"
        done
    ) &
}

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
        # Pause all playing media
        playerctl --all-players pause 2>/dev/null || true
        # Also play a sound if available
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
        ;;
    3)
        # 11:30-11:59 PM - Very serious
        notify-send -u critical -t 20000 "SERIOUSLY, BED NOW! $EMOJI" "It's past 11:30 PM! You said you wanted better sleep habits!"
        # Pause all playing media
        playerctl --all-players pause 2>/dev/null || true
        # Flash the screen using Hyprland
        flash_screen 3 0.2
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
        ;;
    4)
        # 00:00-00:29 AM - Critical
        notify-send -u critical -t 30000 "FINAL WARNING! $EMOJI" "$MESSAGE"
        # Pause all playing media
        playerctl --all-players pause 2>/dev/null || true
        # More aggressive screen flash
        flash_screen 5 0.1
        # Play sound multiple times
        for i in {1..3}; do
            paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
            sleep 1
        done
        # Lock the screen
        hyprlock &
        ;;
    5)
        # 00:30-00:59 AM - More critical
        notify-send -u critical -t 45000 "YOU'RE STILL AWAKE?! $EMOJI" "It's $(date +%H:%M)! $MESSAGE"
        # Pause all playing media
        playerctl --all-players pause 2>/dev/null || true
        # Flash and sound
        flash_screen 7 0.08
        for i in {1..5}; do
            paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
            sleep 0.5
        done
        # Lock the screen
        hyprlock &
        ;;
    6)
        # 01:00-05:59 AM - DEFCON 1 - Maximum annoyance
        notify-send -u critical -t 60000 "YOU'RE STILL AWAKE?! $EMOJI" "It's $(date +%H:%M)! $MESSAGE"
        # Pause all playing media
        playerctl --all-players pause 2>/dev/null || true

        # Show persistent on-screen warning via Hyprland notification
        hyprctl notify 0 10000 "rgb(ff0000)" "fontsize:26 GO TO BED! It's $(date +%H:%M)!"

        # Flash screen aggressively
        flash_screen 10 0.05

        # Play alarm sound on loop for 10 seconds
        timeout 10s bash -c 'while true; do paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true; done'
        # Lock the screen
        hyprlock &
        ;;
esac