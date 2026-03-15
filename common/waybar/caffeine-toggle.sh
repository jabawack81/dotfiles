#!/bin/bash
# Cycle power states: normal → caffeine → remote → hibernate → normal
# Each state runs hypridle with a different config (or kills it for caffeine)
# Pass "reset" as argument to go directly to normal (right-click action)

STATE_FILE="$HOME/.cache/caffeine-state"
state=$(cat "$STATE_FILE" 2>/dev/null || echo "normal")

restart_hypridle() {
    pkill -x hypridle 2>/dev/null
    sleep 0.3
    if [[ -n "$1" ]]; then
        hyprctl dispatch exec "hypridle -c $1"
    else
        hyprctl dispatch exec hypridle
    fi
}

# Right-click reset: return to normal from any state
if [[ "$1" == "reset" ]]; then
    echo "normal" > "$STATE_FILE"
    restart_hypridle
    sleep 0.3
    pkill -RTMIN+9 waybar
    exit 0
fi

case "$state" in
    normal)
        # → Caffeine: kill hypridle, screen stays awake
        pkill -x hypridle 2>/dev/null
        echo "caffeine" > "$STATE_FILE"
        ;;
    caffeine)
        # → Remote: short idle timers, no suspend/hibernate
        echo "remote" > "$STATE_FILE"
        restart_hypridle ~/.config/hypr_common/hypridle-remote.conf
        ;;
    remote)
        # → Hibernate: short idle timers, then hibernate
        echo "hibernate" > "$STATE_FILE"
        restart_hypridle ~/.config/hypr_common/hypridle-hibernate.conf
        ;;
    hibernate)
        # → Normal: standard idle timers
        echo "normal" > "$STATE_FILE"
        restart_hypridle
        ;;
esac

sleep 0.3
pkill -RTMIN+9 waybar
