#!/bin/bash
# Time status indicator for waybar
# Uses central time-status.sh for consistency

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Call the central severity script with waybar format
exec "$SCRIPT_DIR/time-status.sh" waybar