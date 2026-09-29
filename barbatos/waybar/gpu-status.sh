#!/bin/bash

# GPU status for waybar custom module
# Shows EnvyControl mode + NVIDIA stats when available

mode=$(envycontrol --query 2>/dev/null || echo "unknown")

# Set icon based on GPU mode
case "$mode" in
  hybrid)   icon="󰢮" ;; # hybrid icon
  nvidia)   icon="󰍛" ;; # GPU icon
  integrated) icon="󰍹" ;; # monitor icon (Intel only)
  *)        icon="󰢮" ;;
esac

# Try to get NVIDIA stats
if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
  read -r temp util mem_used mem_total <<< \
    "$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total \
       --format=csv,noheader,nounits 2>/dev/null | tr -d ' '  | tr ',' ' ')"

  # Power draw (may return [N/A] on some GPUs)
  power=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits 2>/dev/null | tr -d ' ')
  if [[ "$power" == *"N/A"* ]] || [[ -z "$power" ]]; then
    power_str="N/A"
  else
    power_str="${power}W"
  fi

  tooltip="GPU: ${mode}\nTemp: ${temp}°C\nUtil: ${util}%\nVRAM: ${mem_used}/${mem_total} MiB\nPower: ${power_str}"
  text="${icon} ${temp}°"

  # Set CSS class based on temperature
  if [[ "$temp" -ge 75 ]]; then
    class="critical"
  elif [[ "$temp" -ge 60 ]]; then
    class="warning"
  else
    class="$mode"
  fi
else
  tooltip="GPU: ${mode}\nNVIDIA GPU not active"
  text="${icon}"
  class="$mode"
fi

echo "{\"text\": \"${text}\", \"tooltip\": \"${tooltip}\", \"class\": \"${class}\"}"
