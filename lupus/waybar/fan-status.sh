#!/bin/bash

# Fan status for waybar custom module
# Shows ThinkPad fan speed and level

# Read fan info from /proc/acpi/ibm/fan
fan_file="/proc/acpi/ibm/fan"

if [[ -r "$fan_file" ]]; then
  speed=$(grep "^speed:" "$fan_file" | awk '{print $2}')
  level=$(grep "^level:" "$fan_file" | awk '{print $2}')
else
  echo "{\"text\": \"󰠝 --\", \"tooltip\": \"Fan control not available\", \"class\": \"disabled\"}"
  exit 0
fi

# Icon based on fan level
icon="󰠝"  # fan icon

# Format RPM nicely
if [[ -n "$speed" && "$speed" =~ ^[0-9]+$ ]]; then
  text="${icon} ${speed}"
else
  text="${icon} --"
fi

# Tooltip with full info
tooltip="Fan: ${level}\nSpeed: ${speed} RPM"

# CSS class based on level/speed
case "$level" in
  auto)      class="auto" ;;
  0|1)       class="low" ;;
  2|3)       class="medium" ;;
  4|5)       class="high" ;;
  6|7|"full-speed"|disengaged) class="critical" ;;
  *)         class="unknown" ;;
esac

echo "{\"text\": \"${text}\", \"tooltip\": \"${tooltip}\", \"class\": \"${class}\"}"
