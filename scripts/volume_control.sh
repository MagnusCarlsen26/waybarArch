#!/bin/bash

# Check if an argument (up/down) is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <up|down>"
    exit 1
fi

ACTION=$1
INCREMENT=2

# Get current volume percentage (takes the first channel's volume if multiple)
current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n1)

if [ -z "$current_volume" ]; then
    echo "Could not determine current volume."
    exit 1
fi

if [ "$ACTION" == "up" ]; then
    desired_volume=$((current_volume + INCREMENT))
    # Cap at 100%
    if [ "$desired_volume" -gt 100 ]; then
        new_volume=100
    else
        new_volume=$desired_volume
    fi
elif [ "$ACTION" == "down" ]; then
    desired_volume=$((current_volume - INCREMENT))
    # Cap at 0%
    if [ "$desired_volume" -lt 0 ]; then
        new_volume=0
    else
        new_volume=$desired_volume
    fi
else
    echo "Invalid action: $ACTION. Use 'up' or 'down'."
    exit 1
fi

# Set the volume
pactl set-sink-volume @DEFAULT_SINK@ "${new_volume}%"

# Refresh Waybar
pkill -SIGRTMIN+1 waybar
