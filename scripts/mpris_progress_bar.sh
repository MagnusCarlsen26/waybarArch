#!/bin/bash

# --- Configuration ---
BAR_WIDTH=30      # Width of progress bar
FILLED_CHAR="━"     # Character for filled part
EMPTY_CHAR="─"      # Character for empty part
FILLED_COLOR="#A6E3A1" # Green for filled portion
EMPTY_COLOR="#6C7086"  # Gray for empty portion

# --- Logic ---
if ! command -v playerctl &> /dev/null; then
    echo ""
    exit 1
fi

player_status=$(playerctl status 2>/dev/null)

if [[ "$player_status" == "Playing" || "$player_status" == "Paused" ]]; then
    position_sec_float=$(playerctl metadata --format '{{position/1000000}}' 2>/dev/null)
    length_sec_float=$(playerctl metadata --format '{{mpris:length/1000000}}' 2>/dev/null)
    
    # Check if we have valid position and length data
    if [[ "$position_sec_float" =~ ^[0-9]+([.][0-9]+)?$ && \
          "$length_sec_float" =~ ^[0-9]+([.][0-9]+)?$ && \
          $(echo "$length_sec_float > 0" | bc -l) -eq 1 ]]; then
        
        position_sec=${position_sec_float%.*}
        length_sec=${length_sec_float%.*}
        
        if [ "$length_sec" -gt 0 ]; then
            percentage=$(( (position_sec * 100) / length_sec ))
            filled_count=$(( (percentage * BAR_WIDTH) / 100 ))
            
            # Ensure filled_count is within bounds
            if [ "$filled_count" -gt "$BAR_WIDTH" ]; then
                filled_count="$BAR_WIDTH"
            fi
            if [ "$filled_count" -lt 0 ]; then
                filled_count=0
            fi
            empty_count=$(( BAR_WIDTH - filled_count ))
            
            # Build progress bar
            bar_filled=""
            for ((i=0; i<filled_count; i++)); do
                bar_filled+="$FILLED_CHAR"
            done
            
            bar_empty=""
            for ((i=0; i<empty_count; i++)); do
                bar_empty+="$EMPTY_CHAR"
            done
            
            echo -n "<span color='${FILLED_COLOR}'>${bar_filled}</span><span color='${EMPTY_COLOR}'>${bar_empty}</span>"
        else
            echo -n ""
        fi
    else
        echo -n ""
    fi
else
    echo -n ""
fi
