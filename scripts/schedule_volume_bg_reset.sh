#!/bin/bash

DELAY_SECONDS=2 # How long to show the volume background
FLAG_FILE="/tmp/waybar_volume_active.flag"
LOCK_FILE="/tmp/waybar_volume_reset.lock"

# Try to acquire the lock. If flock is available, it's more robust.
# Using a simple noclobber strategy here.
if (set -o noclobber; echo "$$" > "$LOCK_FILE") 2>/dev/null; then
    # Ensure lockfile is removed on exit/interrupt
    trap 'rm -f "$LOCK_FILE"; exit $?' INT TERM EXIT

    # Wait for the specified delay
    sleep "$DELAY_SECONDS"

    # Clear the active flag
    rm -f "$FLAG_FILE" # Or echo "inactive" > "$FLAG_FILE"

    # Signal Waybar to update the mpris-progress module
    pkill -SIGRTMIN+1 waybar

    # Release the lock
    rm -f "$LOCK_FILE"
    trap - INT TERM EXIT # Remove the trap
else
    # Another instance is already scheduled to reset, so this one can exit.
    # This ensures only the latest scroll event's timer effectively runs.
    exit 0
fi
