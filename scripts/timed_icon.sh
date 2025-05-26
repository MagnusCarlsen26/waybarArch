#!/bin/bash

HOUR=13
CLASS_NAME=""

# Determine the state based on the hour of the day
if [ "$HOUR" -ge 6 ] && [ "$HOUR" -lt 12 ]; then
    CLASS_NAME="cloud-sun"
elif [ "$HOUR" -ge 12 ] && [ "$HOUR" -lt 17 ]; then
    CLASS_NAME="sun"
elif [ "$HOUR" -ge 17 ] && [ "$HOUR" -lt 20 ]; then
    CLASS_NAME="moon-cloud"
else # Night time (20-23 and 00-05)
    CLASS_NAME="moon"
fi

# Output JSON.
# The "text" field can be a space; we'll use CSS to show the icon.
# The "class" field will be used by Waybar to apply a CSS class.
printf '{"text": " ", "class": "%s"}\n' "$CLASS_NAME"
