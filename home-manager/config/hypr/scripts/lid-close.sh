#!/bin/sh
# Lid close: disable the internal panel ONLY when another monitor is active.
#
# Why the guard: eDP-1 is usually the only output on this machine. Disabling it
# unconditionally left Hyprland with ZERO monitors, and that state is not
# recoverable from the keyboard:
#   - hypridle's before_sleep_cmd locks the session, so hyprlock starts with no
#     output to draw on; Hyprland renders a locked session with no lock surface
#     as solid black.
#   - the lid-open restore bind has no compositor output to come back to.
# Result was a black screen that survived reopening the lid and needed a reboot.
# See /var/log/suspend-debug.log: every failing cycle logged "monitors: []"
# already at *pre* suspend.
#
# With the panel left enabled, closing the lid still suspends the machine via
# elogind (HandleLidSwitch=suspend), which powers the panel down anyway.

# hyprctl -j monitors lists only ENABLED monitors, so this counts real outputs.
others=$(hyprctl -j monitors 2>/dev/null | jq -r '[.[] | select(.name != "eDP-1")] | length' 2>/dev/null)

# If hyprctl or jq failed we cannot prove an external display exists -> keep the
# panel. Staying visible is always the safe failure mode here.
case "$others" in
  ''|*[!0-9]*) others=0 ;;
esac

if [ "$others" -ge 1 ]; then
  logger -t hypr-lid "close: $others external monitor(s) active -> disabling eDP-1"
  hyprctl keyword monitor "eDP-1, disable"
else
  logger -t hypr-lid "close: eDP-1 is the only output -> leaving it enabled"
fi
