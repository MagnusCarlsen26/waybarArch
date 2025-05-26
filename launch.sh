#!/bin/bash

killall -q waybar

# Wait for processes to shut down
while pgrep -x waybar >/dev/null; do sleep 1; done

waybar -c ~/.config/waybar/config.jsonc&
waybar -c ~/.config/waybar/mpris-progress-config.jsonc &

echo "Waybar instances launched..."
