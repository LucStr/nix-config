#!/bin/sh
export MAIN_DISPLAY=eDP-1
export XCURSOR_SIZE=24

HDMI=$(cat /sys/class/drm/card0-HDMI-A-1/status) # Display in HDMI port
DP=$(cat /sys/class/drm/card0-DP-2/status) # Display in HDMI port

if [ "$HDMI" = 'disconnected' ]; then
  if [ "$DP" = 'disconnected' ]; then	
	export MAIN_DISPLAY=eDP-1
	export XCURSOR_SIZE=24
  else
	export MAIN_DISPLAY=DP-3
	export XCURSOR_SIZE=24
  fi
else
	export MAIN_DISPLAY=HDMI-A-1
	export XCURSOR_SIZE=24
fi
