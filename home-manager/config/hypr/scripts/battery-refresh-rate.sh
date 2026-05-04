#!/bin/sh
# Battery-aware Hyprland session tweaks.
# AC:      eDP-1 @ 240 Hz, hypridle off (don't disrupt long-running tasks).
# Battery: eDP-1 @ 48 Hz,  hypridle on  (dim/dpms/lock/suspend).
# Listens to upower events; reconnects if upowerd ever exits.
#
# Usage:
#   battery-refresh-rate.sh         daemon mode (started via exec-once)
#   battery-refresh-rate.sh --once  apply current state and exit (lid-open bind)

EDP_AC="eDP-1,2560x1600@240,3440x0,1.25"
EDP_BAT="eDP-1,2560x1600@48,3440x0,1.25"

current_state() {
  for online in /sys/class/power_supply/A*/online; do
    [ -f "$online" ] || continue
    [ "$(cat "$online")" = "1" ] && { echo ac; return; }
  done
  echo battery
}

apply() {
  case "$(current_state)" in
    ac)
      hyprctl keyword monitor "$EDP_AC" >/dev/null
      pkill -x hypridle 2>/dev/null || true
      ;;
    battery)
      hyprctl keyword monitor "$EDP_BAT" >/dev/null
      pgrep -x hypridle >/dev/null 2>&1 || setsid hypridle </dev/null >/dev/null 2>&1 &
      ;;
  esac
}

if [ "$1" = "--once" ]; then
  apply
  exit 0
fi

while :; do
  apply
  upower --monitor 2>/dev/null | while IFS= read -r _line; do
    apply
  done
  sleep 5
done
