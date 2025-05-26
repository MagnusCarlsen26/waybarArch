#!/bin/bash

FLAG_FILE="/tmp/waybar_volume_active.flag"
ACTIVE_CLASS="volume-active-indicator"   # For 100% volume fill
INACTIVE_CLASS="volume-inactive-indicator" # For transparent

CURRENT_CLASS="$INACTIVE_CLASS" # Default to inactive/transparent

if [ -f "$FLAG_FILE" ]; then # Check if flag file exists (means active change)
    VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -n 1)
    if ! [[ "$VOLUME" =~ ^[0-9]+$ ]]; then
        VOLUME=0 # Default to 0 if parsing fails
    elif (( VOLUME > 100 )); then
        VOLUME=100
    fi

    # NEW CONDITION: Only show active indicator if volume is 100%
    if [ "$VOLUME" -eq 100 ]; then
        CURRENT_CLASS="$ACTIVE_CLASS"
    else
        # For 0% or 1-99% volume, keep it inactive/transparent
        CURRENT_CLASS="$INACTIVE_CLASS"
    fi
else
    # If flag is not set, always inactive/transparent
    CURRENT_CLASS="$INACTIVE_CLASS"
fi

TEXT_CONTENT="    " # Or "   " if you prefer

echo "{\"text\": \"${TEXT_CONTENT}\", \"class\": \"${CURRENT_CLASS}\"}"