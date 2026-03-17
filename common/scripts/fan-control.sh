#!/bin/bash
# Fan control for desktop motherboards with ITE Super I/O chips (it86xx).
# Provides manual and automatic modes with different aggressiveness levels.
set -euo pipefail

# Find ITE Super I/O hwmon path
HWMON=""
for h in /sys/class/hwmon/hwmon*; do
    name=$(cat "$h/name" 2>/dev/null || true)
    if [[ "$name" == it86* ]]; then
        HWMON="$h"
        break
    fi
done

if [ -z "$HWMON" ]; then
    echo "Error: ITE Super I/O chip not found"
    exit 1
fi

# Detect fans with both an RPM sensor and a PWM control channel
FANS=()
for i in 1 2 3 4 5; do
    if [[ -f "$HWMON/fan${i}_input" && -f "$HWMON/pwm${i}" ]]; then
        FANS+=("$i")
    fi
done

if [ ${#FANS[@]} -eq 0 ]; then
    echo "Error: no controllable fans detected"
    exit 1
fi

set_manual() {
    local pwm_value=$1
    for i in "${FANS[@]}"; do
        echo 1 | sudo tee "$HWMON/pwm${i}_enable" > /dev/null
        echo "$pwm_value" | sudo tee "$HWMON/pwm${i}" > /dev/null
    done
}

set_auto() {
    local start=$1 slope=$2 point1=$3 point2=$4 point3=$5
    for i in "${FANS[@]}"; do
        echo 2 | sudo tee "$HWMON/pwm${i}_enable" > /dev/null
        echo "$start" | sudo tee "$HWMON/pwm${i}_auto_start" > /dev/null
        echo "$slope" | sudo tee "$HWMON/pwm${i}_auto_slope" > /dev/null
        echo "$point1" | sudo tee "$HWMON/pwm${i}_auto_point1_temp" > /dev/null
        echo "$point2" | sudo tee "$HWMON/pwm${i}_auto_point2_temp" > /dev/null
        echo "$point3" | sudo tee "$HWMON/pwm${i}_auto_point3_temp" > /dev/null
    done
}

show_status() {
    for i in "${FANS[@]}"; do
        local rpm pwm enable mode
        rpm=$(cat "$HWMON/fan${i}_input")
        pwm=$(cat "$HWMON/pwm${i}")
        enable=$(cat "$HWMON/pwm${i}_enable")
        case "$enable" in
            0) mode="full" ;; 1) mode="manual" ;; 2) mode="auto" ;; *) mode="?" ;;
        esac
        printf "    fan%d: %4d RPM  %3d%% (%s)\n" "$i" "$rpm" "$((pwm * 100 / 255))" "$mode"
    done
}

apply_mode() {
    case "$1" in
        quiet)
            set_manual 70
            echo "  Set to quiet (~27%)"
            ;;
        max)
            set_manual 255
            echo "  Set to max (100%)"
            ;;
        auto-quiet)
            # Conservative curve: fans stay low until 60°C, full at 85°C
            set_auto 70 22 40000 60000 85000
            echo "  Set to auto quiet (ramp 40-85C)"
            ;;
        auto-aggressive)
            # Aggressive curve: fans ramp early at 40°C, full at 70°C
            set_auto 100 66 30000 45000 70000
            echo "  Set to auto aggressive (ramp 30-70C)"
            ;;
        *)
            echo "Unknown mode: $1"
            echo "Usage: $(basename "$0") [quiet|max|auto-quiet|auto-aggressive]"
            exit 1
            ;;
    esac
}

# Non-interactive mode
if [ $# -gt 0 ]; then
    apply_mode "$1"
    exit 0
fi

# Interactive menu
printf "\n"
printf "  \033[1m\033[36m╔══════════════════════════════════════════════════════╗\033[0m\n"
printf "  \033[1m\033[36m║                Fan Control                           ║\033[0m\n"
printf "  \033[1m\033[36m╚══════════════════════════════════════════════════════╝\033[0m\n"
printf "\n"
printf "  \033[1m\033[32m=== Current Status ===\033[0m\n"
show_status
printf "\n"
printf "  \033[1m\033[32m=== Modes ===\033[0m\n"
printf "   \033[33m1)\033[0m  fan-control quiet            \033[2mManual ~27%% - minimal noise\033[0m\n"
printf "   \033[33m2)\033[0m  fan-control max              \033[2mManual 100%% - full blast\033[0m\n"
printf "   \033[33m3)\033[0m  fan-control auto-quiet       \033[2mAuto curve, ramp 40-85C\033[0m\n"
printf "   \033[33m4)\033[0m  fan-control auto-aggressive  \033[2mAuto curve, ramp 30-70C\033[0m\n"
printf "\n"

read -rp "  Enter choice: " choice
case "$choice" in
    1) apply_mode quiet ;;
    2) apply_mode max ;;
    3) apply_mode auto-quiet ;;
    4) apply_mode auto-aggressive ;;
    *) echo "  Invalid choice" ;;
esac
printf "\n"
