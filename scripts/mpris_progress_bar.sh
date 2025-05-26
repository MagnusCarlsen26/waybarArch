#!/bin/bash

# --- Configuration ---
BAR_WIDTH=30
FILLED_CHAR="━"     # U+2501
EMPTY_CHAR="─"      # U+2500
FILLED_COLOR="#A6E3A1"
EMPTY_COLOR="#6C7086"
FLAG_FILE="/tmp/waybar_volume_active.flag"
LOG_FILE="/tmp/mpris_progress_debug.log"

echo "--- Script run at $(date) ---" >> "$LOG_FILE"

# --- Initialize PROGRESS_BAR_TEXT ---
PROGRESS_BAR_TEXT=""

# --- Logic for MPRIS Progress Bar ---
if command -v playerctl &> /dev/null; then
    player_status=$(playerctl status 2>/dev/null)
    if [[ "$player_status" == "Playing" || "$player_status" == "Paused" ]]; then
        position_sec_float=$(playerctl metadata --format '{{position/1000000}}' 2>/dev/null)
        length_sec_float=$(playerctl metadata --format '{{mpris:length/1000000}}' 2>/dev/null)
        if [[ "$position_sec_float" =~ ^[0-9]+([.][0-9]+)?$ && \
              "$length_sec_float" =~ ^[0-9]+([.][0-9]+)?$ && \
              $(echo "$length_sec_float > 0" | bc -l) -eq 1 ]]; then
            position_sec=${position_sec_float%.*}
            length_sec=${length_sec_float%.*}
            if [ "$length_sec" -gt 0 ]; then
                percentage=$(( (position_sec * 100) / length_sec ))
                filled_count=$(( (percentage * BAR_WIDTH) / 100 ))
                [ "$filled_count" -gt "$BAR_WIDTH" ] && filled_count="$BAR_WIDTH"
                [ "$filled_count" -lt 0 ] && filled_count=0
                empty_count=$(( BAR_WIDTH - filled_count ))

                # --- MODIFIED BAR GENERATION ---
                bar_filled=""
                idx=0
                while [ "$idx" -lt "$filled_count" ]; do
                    bar_filled="${bar_filled}${FILLED_CHAR}"
                    idx=$((idx + 1))
                done

                bar_empty=""
                idx=0
                while [ "$idx" -lt "$empty_count" ]; do
                    bar_empty="${bar_empty}${EMPTY_CHAR}"
                    idx=$((idx + 1))
                done
                # --- END OF MODIFIED BAR GENERATION ---

                PROGRESS_BAR_TEXT="<span color='${FILLED_COLOR}'>${bar_filled}</span><span color='${EMPTY_COLOR}'>${bar_empty}</span>"
            fi
        fi
    fi
fi
echo "PROGRESS_BAR_TEXT: [${PROGRESS_BAR_TEXT}]" >> "$LOG_FILE"

# --- Determine Background Class for mpris-progress (rest of your script) ---
VOLUME_CLASS="volume-bg-transparent"

if [ -f "$FLAG_FILE" ]; then
    echo "FLAG_FILE ($FLAG_FILE) exists." >> "$LOG_FILE"
    RAW_PACT_OUTPUT=$(pactl get-sink-volume @DEFAULT_SINK@)
    echo "Raw pactl output: $RAW_PACT_OUTPUT" >> "$LOG_FILE"
    VOLUME=$(echo "$RAW_PACT_OUTPUT" | grep -Po '[0-9]+(?=%)' | head -n 1)
    echo "Initial parsed VOLUME: [$VOLUME]" >> "$LOG_FILE"

    if ! [[ "$VOLUME" =~ ^[0-9]+$ ]]; then
        echo "Volume parsing failed or was empty. Defaulting VOLUME to 0." >> "$LOG_FILE"
        VOLUME=0
    elif (( VOLUME > 100 )); then
        echo "Volume $VOLUME was > 100. Capping VOLUME to 100." >> "$LOG_FILE"
        VOLUME=100
    fi
    echo "Final processed VOLUME: [$VOLUME]" >> "$LOG_FILE"

    if [ "$VOLUME" -eq 0 ]; then
        VOLUME_CLASS="volume-bg-transparent"
        echo "Condition: VOLUME is 0. Setting class to $VOLUME_CLASS" >> "$LOG_FILE"
    else
        VOLUME_CLASS="volume-bg-${VOLUME}"
        echo "Condition: VOLUME is > 0. Setting class to $VOLUME_CLASS" >> "$LOG_FILE"
    fi
else
    echo "FLAG_FILE ($FLAG_FILE) does NOT exist. Setting class to $VOLUME_CLASS" >> "$LOG_FILE"
fi

JSON_OUTPUT="{\"text\": \"${PROGRESS_BAR_TEXT}\", \"class\": \"${VOLUME_CLASS}\"}"
echo "Final JSON Output: $JSON_OUTPUT" >> "$LOG_FILE"
echo "$JSON_OUTPUT"
