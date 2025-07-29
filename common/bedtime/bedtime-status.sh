#!/bin/bash
# Bedtime status indicator for waybar

HOUR=$(date +%-H)
DAY=$(date +%u) # 1=Monday, 7=Sunday

# Check if it's a school night (Sunday-Thursday nights)
is_schoolnight() {
    [ $DAY -ne 5 ] && [ $DAY -ne 6 ]
}

# Only show status on school nights after 10 PM
if ! is_schoolnight; then
    # Weekend - no bedtime reminder
    echo '{"text": "", "tooltip": "Weekend - no bedtime!", "class": "weekend"}'
    exit 0
fi

# Get emoji based on time
if [ $HOUR -ge 23 ] || [ $HOUR -lt 6 ]; then
    if [ $HOUR -eq 0 ] || [ $HOUR -lt 6 ]; then
        # Past midnight - angry face
        echo '{"text": "😡", "tooltip": "GO TO BED NOW! It'"'"'s way past bedtime!", "class": "critical"}'
    else
        # 11 PM - warning
        echo '{"text": "😴", "tooltip": "Time for bed! Click to check bedtime status", "class": "warning"}'
    fi
else
    # Before 11 PM - all good
    echo '{"text": "😊", "tooltip": "Not bedtime yet", "class": "good"}'
fi