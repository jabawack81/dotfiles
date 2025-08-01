#!/bin/bash
# Bedtime indicator arrow after
# Gets the severity from central script and returns appropriate arrow

# Get class from central script (just the class, not full status)
CLASS=$(HOUR=${HOUR:-$(date +%-H)} DAY=${DAY:-$(date +%u)} $HOME/.config/bedtime/time-status.sh status | grep "^class=" | cut -d= -f2)

# Output arrow with matching class
echo "{\"text\": \"\ue0b2\", \"class\": \"bedtime-$CLASS\"}"