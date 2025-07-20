#!/bin/bash
# Common temperature monitoring script
# Usage: ./temperature-common.sh <device> <format> [icon]
# device: cpu or gpu
# format: full (with icon and text) or arrow (just arrow)
# icon: optional icon for full format

device=$1
format=$2
icon=$3

# Determine temperature source
TEST_FILE="/tmp/waybar-temp-test.conf"

# Get temperature based on device
case "$device" in
  cpu)
    if [ -f "$TEST_FILE" ]; then
      source "$TEST_FILE"
      temp="${WAYBAR_CPU_TEMP:-45000}"
    else
      temp=$(cat /sys/class/hwmon/hwmon3/temp1_input)
    fi
    ;;
  gpu)
    if [ -f "$TEST_FILE" ]; then
      source "$TEST_FILE"
      temp="${WAYBAR_GPU_TEMP:-45000}"
    else
      temp=$(cat /sys/class/hwmon/hwmon6/temp1_input)
    fi
    ;;
  *)
    echo "Error: Unknown device: $device" >&2
    exit 1
    ;;
esac

# Convert to Celsius
temp_c=$((temp / 1000))

# Determine temperature state
if [ $temp_c -ge 80 ]; then
  state="critical"
elif [ $temp_c -ge 60 ]; then
  state="warning"
else
  state="normal"
fi

# Output based on format
if [ "$format" = "full" ]; then
  # Get device display name
  case "$device" in
    cpu)
      device_name="CPU"
      ;;
    gpu)
      device_name="GPU"
      ;;
    *)
      device_name="Unknown"
      ;;
  esac
  echo "{\"text\": \"$icon  ${temp_c}°C\", \"class\": \"$state\", \"tooltip\": \"$device_name Temperature: ${temp_c}°C\"}"
elif [ "$format" = "arrow-before" ]; then
  echo "{\"text\": \"\", \"class\": \"$state\"}"
elif [ "$format" = "arrow-after" ]; then
  echo "{\"text\": \"\", \"class\": \"$state\"}"
fi

