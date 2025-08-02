#!/bin/bash
# Test script to display bedtime emoji table for all days and hours

# Color codes for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Day names
DAYS=("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun")

# Path to the time-status script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIME_STATUS_SCRIPT="$SCRIPT_DIR/time-status.sh"

echo "🕐 Bedtime System - Complete Hour/Day Emoji Table 🕐"
echo "======================================================"
echo

# Print header with day names
printf "%4s" "Hour"
for day in "${DAYS[@]}"; do
    printf "%6s" "$day"
done
echo
echo "    ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐"

# Loop through all hours (0-23)
for hour in {0..23}; do
    printf "%2d:00│" "$hour"
    
    # Loop through all days (1=Monday, 7=Sunday)
    for day in {1..7}; do
        # Get emoji from time-status script
        emoji=$(HOUR=$hour DAY=$day bash "$TIME_STATUS_SCRIPT" emoji 2>/dev/null)
        
        # If emoji is empty or script failed, show error
        if [ -z "$emoji" ]; then
            emoji="❌"
        fi
        
        # Color the emoji based on type for better visualization
        case "$emoji" in
            "🍽️") colored_emoji="${YELLOW}$emoji${NC}" ;;  # Lunch
            "💼") colored_emoji="${BLUE}$emoji${NC}" ;;    # Work
            "🎉") colored_emoji="${PURPLE}$emoji${NC}" ;;  # Weekend
            "😊") colored_emoji="${GREEN}$emoji${NC}" ;;   # All good
            "🌙") colored_emoji="${CYAN}$emoji${NC}" ;;    # Wind down
            "😡") colored_emoji="${YELLOW}$emoji${NC}" ;;  # Go to bed
            "💀") colored_emoji="${RED}$emoji${NC}" ;;     # Way past bedtime
            *) colored_emoji="$emoji" ;;
        esac
        
        printf " %s  " "$colored_emoji"
    done
    echo "│"
done

echo "    └─────┴─────┴─────┴─────┴─────┴─────┴─────┘"
echo

# Legend
echo "📋 Legend:"
echo "   🍽️  Lunch time (12-1PM weekdays)"
echo "   💼  Work hours (9AM-6PM weekdays)"  
echo "   🎉  Weekend time"
echo "   😊  All good (normal time)"
echo "   🌙  Wind down (10-11PM school nights)"
echo "   😡  Go to bed (11PM-midnight school nights)"
echo "   💀  Way past bedtime (midnight-6AM school nights)"
echo

# Additional detailed breakdown for current time
current_hour=$(date +%-H)
current_day=$(date +%u)
current_day_name="${DAYS[$((current_day-1))]}"

echo "🔍 Current Status Analysis:"
echo "   Time: $current_hour:00 on $current_day_name"

# Get full status for current time
status_output=$(HOUR=$current_hour DAY=$current_day bash "$TIME_STATUS_SCRIPT" status 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "   $status_output" | while IFS= read -r line; do
        if [[ $line == emoji=* ]]; then
            emoji=${line#emoji=}
            echo "   Current emoji: $emoji"
        elif [[ $line == message=* ]]; then
            message=${line#message=}
            echo "   Message: $message"
        elif [[ $line == class=* ]]; then
            class=${line#class=}
            echo "   Class: $class"
        fi
    done
else
    echo "   ❌ Error getting current status"
fi

echo
echo "✅ Test completed! Check the table above to verify bedtime logic."