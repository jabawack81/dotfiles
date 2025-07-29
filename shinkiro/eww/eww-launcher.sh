#!/bin/bash
# EWW launcher script

# Kill any existing eww instances
pkill -x eww

# Wait a moment for cleanup
sleep 1

# Start eww daemon
~/.local/bin/eww daemon

# Wait for daemon to be ready
sleep 1

# Open dashboard windows (no background)
~/.local/bin/eww open-many \
    profile \
    system \
    clock \
    uptime \
    network \
    music \
    social \
    weather \
    apps \
    logout \
    sleep \
    reboot \
    poweroff \
    folders