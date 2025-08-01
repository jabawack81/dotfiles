#!/bin/bash
# Central time status indicator - tracks work, lunch, and bedtime hours
# Returns status level and associated data in various formats

# Allow environment override for testing, otherwise use current time
HOUR=${HOUR:-$(date +%-H)}
DAY=${DAY:-$(date +%u)} # 1=Monday, 7=Sunday

# Check if it's a school night (Sunday-Thursday nights)
is_schoolnight() {
    [ $DAY -ne 5 ] && [ $DAY -ne 6 ]
}

# Check if it's a weekday (Monday-Friday)
is_weekday() {
    [ $DAY -ge 1 ] && [ $DAY -le 5 ]
}

# Check if it's work hours (9 AM - 6 PM on weekdays)
is_workhours() {
    is_weekday && [ $HOUR -ge 9 ] && [ $HOUR -lt 18 ]
}

# Check if it's lunch time (12 PM - 1 PM on weekdays)
is_lunchtime() {
    is_weekday && [ $HOUR -eq 12 ]
}

# Get severity level based on time
# Returns: 0=not bedtime, 1=wind down, 2=bedtime, 3=way past bedtime, -1=weekend, -2=work hours, -3=lunch time
get_severity() {
    # Check lunch time first (only on weekdays)
    if is_lunchtime; then
        echo "-3"  # Lunch time
        return
    fi
    
    # Check work hours (only on weekdays)
    if is_workhours; then
        echo "-2"  # Work hours
        return
    fi
    
    if ! is_schoolnight; then
        echo "-1"  # Weekend
        return
    fi
    
    if [ $HOUR -ge 22 ] && [ $HOUR -lt 23 ]; then
        echo "1"  # 10-11 PM - Wind down
    elif [ $HOUR -eq 23 ]; then
        echo "2"  # 11 PM to midnight - Go to bed
    elif [ $HOUR -ge 0 ] && [ $HOUR -lt 6 ]; then
        echo "3"  # After midnight - Way past bedtime
    else
        echo "0"  # Not bedtime yet
    fi
}

# Get emoji for severity level
get_emoji() {
    local severity=$1
    case $severity in
        -3) echo "🍽️" ;;  # Lunch time
        -2) echo "💼" ;;  # Work hours
        -1) echo "🎉" ;;  # Weekend
        0)  echo "😊" ;;  # All good
        1)  echo "🌙" ;;  # Wind down
        2)  echo "😡" ;;  # Go to bed
        3)  echo "💀" ;;  # Way past bedtime
        *)  echo "?" ;;
    esac
}

# Get message for severity level
get_message() {
    local severity=$1
    case $severity in
        -3) echo "Lunch time - take a break!" ;;
        -2) echo "Work hours - stay focused!" ;;
        -1) echo "Weekend - no bedtime!" ;;
        0)  echo "Not bedtime yet" ;;
        1)  echo "Getting late - wind down for bed soon" ;;
        2)  echo "GO TO BED NOW! It's way past bedtime!" ;;
        3)  echo "Seriously?! It's $(printf "%02d:00" $HOUR) - this is self-sabotage!" ;;
        *)  echo "Unknown" ;;
    esac
}

# Get CSS class for waybar
get_css_class() {
    local severity=$1
    case $severity in
        -3) echo "lunch" ;;   # Lunch time
        -2) echo "work" ;;    # Work hours
        -1) echo "weekend" ;;
        0)  echo "good" ;;
        1)  echo "info" ;;
        2)  echo "warning" ;;
        3)  echo "critical" ;;
        *)  echo "unknown" ;;
    esac
}

# Get terminal color codes
get_terminal_format() {
    local severity=$1
    case $severity in
        -1) echo "" ;;  # No format for weekend
        0)  echo "" ;;  # No format when all good
        1)  echo "yellow" ;;
        2)  echo "red" ;;
        3)  echo "red" ;;
        *)  echo "" ;;
    esac
}

# Get short text for terminal prompt
get_short_text() {
    local severity=$1
    case $severity in
        1)  echo "Wind down" ;;
        2)  echo "GO TO BED!" ;;
        3)  echo "SLEEP NOW!" ;;
        *)  echo "" ;;
    esac
}

# Main logic - handle different output formats
SEVERITY=$(get_severity)

case "${1:-status}" in
    severity)
        # Just return the severity number
        echo "$SEVERITY"
        ;;
    
    emoji)
        # Just return the emoji
        get_emoji "$SEVERITY"
        ;;
    
    message)
        # Just return the message
        get_message "$SEVERITY"
        ;;
    
    waybar|json)
        # Return JSON for waybar
        emoji=$(get_emoji "$SEVERITY")
        message=$(get_message "$SEVERITY")
        class=$(get_css_class "$SEVERITY")
        echo "{\"text\": \"$emoji\", \"tooltip\": \"$message\", \"class\": \"$class\"}"
        ;;
    
    terminal)
        # Return formatted string for terminal prompt
        if [ "$SEVERITY" -gt 0 ] && [ "$SEVERITY" -ne -1 ]; then
            emoji=$(get_emoji "$SEVERITY")
            text=$(get_short_text "$SEVERITY")
            color=$(get_terminal_format "$SEVERITY")
            echo "${color}:${emoji} ${text}"
        fi
        ;;
    
    notify)
        # Return notification urgency level for dunst
        case $SEVERITY in
            1)  echo "normal" ;;
            2)  echo "critical" ;;
            3)  echo "critical" ;;
            *)  echo "none" ;;
        esac
        ;;
    
    status|*)
        # Default: return all info as key=value pairs
        echo "severity=$SEVERITY"
        echo "emoji=$(get_emoji "$SEVERITY")"
        echo "message=$(get_message "$SEVERITY")"
        echo "class=$(get_css_class "$SEVERITY")"
        echo "is_schoolnight=$(is_schoolnight && echo "true" || echo "false")"
        echo "hour=$HOUR"
        echo "day=$DAY"
        ;;
esac