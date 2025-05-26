#!/bin/bash

# Get current volume percentage (0-100)
VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -n 1)

# Fallback if volume parsing fails
# if ! [[ "$VOLUME" =~ ^[0-9]+$ ]]; then
#     VOLUME=0
# elif (( VOLUME > 100 )); then
#     VOLUME=100 # Cap at 100
# fi

# Output JSON. The "text" can be empty or a space as it's just a background.
# The class name will be like "volume-bg-0", "volume-bg-60", "volume-bg-100".
echo "{\"text\": \" \", \"class\": \"volume-bg-${VOLUME}\"}"
