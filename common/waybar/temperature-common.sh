#!/bin/bash
# Common temperature monitoring script
# Usage: ./temperature-common.sh <device> <format> [icon]
# device: cpu or gpu
# format: full (with icon and text) or arrow-before or arrow-after
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
    # Find coretemp (Intel) or k10temp (AMD) hwmon device
    for hwmon in /sys/class/hwmon/hwmon*/; do
      hwmon_name=$(cat "$hwmon/name" 2>/dev/null)
      if [ "$hwmon_name" = "coretemp" ] || [ "$hwmon_name" = "k10temp" ]; then
        temp=$(cat "$hwmon/temp1_input" 2>/dev/null || echo "0")
        break
      fi
    done
    # Fallback to first available temperature
    if [ "$temp" = "0" ] || [ -z "$temp" ]; then
      temp=$(cat /sys/class/hwmon/hwmon*/temp*_input 2>/dev/null | head -1 || echo "0")
    fi
  fi
  ;;
gpu)
  if [ -f "$TEST_FILE" ]; then
    source "$TEST_FILE"
    temp="${WAYBAR_GPU_TEMP:-45000}"
  else
    # Find AMD GPU hwmon device
    for hwmon in /sys/class/hwmon/hwmon*/; do
      hwmon_name=$(cat "$hwmon/name" 2>/dev/null)
      if [ "$hwmon_name" = "amdgpu" ]; then
        temp=$(cat "$hwmon/temp1_input" 2>/dev/null || echo "0")
        break
      fi
    done
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
  if [ -n "$icon" ]; then
    echo "{\"text\": \"$icon  ${temp_c}°C\", \"class\": \"$state\", \"tooltip\": \"$device_name Temperature: ${temp_c}°C\"}"
  else
    echo "{\"text\": \"${temp_c}°C\", \"class\": \"$state\", \"tooltip\": \"$device_name Temperature: ${temp_c}°C\"}"
  fi
elif [ "$format" = "arrow-before" ]; then
  echo "{\"text\": \"\ue0b2\", \"class\": \"$state\"}"
elif [ "$format" = "arrow-after" ]; then
  echo "{\"text\": \"\ue0b2\", \"class\": \"$state\"}"
fi

