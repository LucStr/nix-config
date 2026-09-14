#!/bin/sh
# Battery-aware Hyprland session tweaks.
# AC:      eDP-1 @ 240 Hz, hypridle off (don't disrupt long-running tasks).
# Battery: eDP-1 @ 48 Hz,  hypridle on  (dim/dpms/lock/suspend).
# Listens to upower events; reconnects if upowerd ever exits.
#
# Usage:
#   battery-refresh-rate.sh         daemon mode (started via exec-once)
#   battery-refresh-rate.sh --once  apply current state and exit (lid-open bind,
#                                   and hypridle's after_sleep_cmd)

EDP_RES="2560x1600"
EDP_POS="3440x0"
EDP_SCALE="1.25"
EDP_HZ_AC="240"
EDP_HZ_BAT="48"

current_state() {
  for online in /sys/class/power_supply/A*/online; do
    [ -f "$online" ] || continue
    [ "$(cat "$online")" = "1" ] && { echo ac; return; }
  done
  echo battery
}

# True if eDP-1 is enabled and already at $1 Hz with the wanted resolution and
# scale. Position is deliberately NOT compared: Hyprland normalises a lone
# monitor back to the origin, so the configured 3440x0 would never match and we
# would modeset on every single call.
edp_is_at() {
  hyprctl -j monitors 2>/dev/null | jq -e \
    --arg res "$EDP_RES" --arg hz "$1" --arg scale "$EDP_SCALE" '
      any(.[];
            .name == "eDP-1"
        and "\(.width)x\(.height)" == $res
        and (.refreshRate | round) == ($hz | tonumber)
        and (.scale * 1000 | round) == ($scale | tonumber * 1000 | round)
      )' >/dev/null 2>&1
}

# True if eDP-1 is absent from the enabled monitor list, i.e. a lid-close
# disabled it (only happens when an external display was attached).
edp_is_disabled() {
  ! hyprctl -j monitors 2>/dev/null | jq -e 'any(.[]; .name == "eDP-1")' >/dev/null 2>&1
}

# Last power state we acted on. Empty means "never", so the first call always
# settles hypridle.
LAST_APPLIED=""

apply() {
  state="$(current_state)"
  case "$state" in
    ac) want_hz="$EDP_HZ_AC" ;;
    *)  want_hz="$EDP_HZ_BAT" ;;
  esac

  # Only touch the monitor when it is actually wrong.
  #
  # This runs from three places at once on resume: the lid-open bind, hypridle's
  # after_sleep_cmd, and the upower daemon loop (which fires on every battery
  # percentage poll, ~30s, even with no state change). Re-keywording eDP-1 each
  # time produced a burst of five modesets on a single lid-open, alternating
  # 2880x1800@120/scale 1.00 and 2560x1600@48/scale 1.25. That was visible as
  # flicker, it destroyed hyprpaper's layer surface so the wallpaper never came
  # back, and it left Hyprland warning "SessionLockSurface object remains but
  # surface is being destroyed???".
  if ! edp_is_at "$want_hz"; then
    logger -t hypr-lid "apply: state=$state -> ${EDP_RES}@${want_hz} scale ${EDP_SCALE}"
    # Only needed when a lid-close actually disabled the panel. Doing this
    # unconditionally added a second pointless modeset, at a different
    # resolution AND scale, on every single resume.
    if edp_is_disabled; then
      logger -t hypr-lid "apply: eDP-1 was disabled, re-enabling"
      hyprctl keyword monitor "eDP-1, preferred, auto, 1" >/dev/null
    fi
    hyprctl keyword monitor "eDP-1,${EDP_RES}@${want_hz},${EDP_POS},${EDP_SCALE}" >/dev/null
  fi

  # hypridle only needs settling on a real power-state change.
  if [ "$state" != "$LAST_APPLIED" ]; then
    case "$state" in
      ac)
        pkill -x hypridle 2>/dev/null || true
        ;;
      battery)
        pgrep -x hypridle >/dev/null 2>&1 || setsid hypridle </dev/null >/dev/null 2>&1 &
        ;;
    esac
    LAST_APPLIED="$state"
  fi
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
