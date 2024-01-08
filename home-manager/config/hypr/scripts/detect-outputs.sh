#!/bin/sh
export XCURSOR_SIZE=24

# Function to check display status
check_display() {
  if [ -f "$1" ]; then
    status=$(cat "$1")
    echo $status
    if [ "$status" = "connected" ]; then
      echo "$2"
      return 0
    fi
  fi
  return 1
}

# Define order of preference for displays
declare -a displays=("/sys/class/drm/card1-HDMI-A-5/status HDMI-A-5" "/sys/class/drm/card0-DP-2/status DP-2")

# Default display
export MAIN_DISPLAY="eDP-1"

# Check each display in order of preference
for display_info in "${displays[@]}"; do
  read -r file display <<< "$display_info"
  if check_display "$file" "$display"; then
    export MAIN_DISPLAY="$display"
    echo $MAIN_DISPLAY
    break
  fi
done
