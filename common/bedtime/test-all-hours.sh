#!/bin/bash
# Test script to display bedtime emoji table for all days and hours

# Check if we should use colors (default: yes, unless --no-color is passed)
USE_COLORS=true
if [[ "$1" == "--no-color" ]]; then
  USE_COLORS=false
fi

# Day names
DAYS=("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun")

# Path to the time-status script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIME_STATUS_SCRIPT="$SCRIPT_DIR/time-status.sh"

echo "🕐 Bedtime System - Complete Hour/Day Emoji Table 🕐"
echo "======================================================"
if [ "$USE_COLORS" = true ]; then
  echo "(Using background colors - run with --no-color to disable)"
else
  echo "(Colors disabled)"
fi
echo

# Print header with day names
printf "%4s" "Hour"
for day in "${DAYS[@]}"; do
  printf "%6s" "$day"
done
echo
echo "     ┌──────┬──────┬──────┬──────┬──────┬──────┬──────┐"

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

    # Display emoji with optional background colors from time-status script
    if [ "$USE_COLORS" = true ]; then
      # Get background color from time-status script
      bg_color=$(HOUR=$hour DAY=$day bash "$TIME_STATUS_SCRIPT" background 2>/dev/null)
      
      if [ -n "$bg_color" ]; then
        printf " \033[%sm %s \033[0m │" "$bg_color" "$emoji"
      else
        printf " %s  │" "$emoji"
      fi
    else
      printf " %s  │" "$emoji"
    fi
  done
  echo ""

done

echo "     └──────┴──────┴──────┴──────┴──────┴──────┴──────┘"
echo

# Legend
echo "📋 Legend:"
echo "   🍝  Lunch time (12-1PM weekdays)"
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
current_day_name="${DAYS[$((current_day - 1))]}"

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
