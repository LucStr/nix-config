#!/bin/sh
# Battery-aware Hyprland session tweaks.
# AC:      eDP-1 @ 240 Hz, idle timers off (don't disrupt long-running tasks).
# Battery: eDP-1 @ 48 Hz,  idle timers on  (dim/dpms/lock/suspend).
# The timers are a second hypridle instance (hypridle-battery.conf); the
# always-on one (hypridle.conf, lock before sleep) is never touched here.
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

HYPRIDLE_BATTERY_CONF="$HOME/.config/hypr/hypridle-battery.conf"
# Matches only the battery instance: anchored on argv[0], so neither the
# always-on hypridle nor an editor with the file open can match.
HYPRIDLE_BATTERY_PAT="^hypridle -c $HYPRIDLE_BATTERY_CONF\$"

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

# True if the laptop lid is shut. If the ACPI node is missing or unreadable we
# answer "open": that keeps the old behaviour of healing a disabled panel, which
# is the safe failure mode (a visible screen beats an invisible one).
# Persisted lid rule, sourced last by hyprland.conf. Clearing it on lid open is
# what lets a later config reload bring the panel back; leaving it in place
# would keep eDP-1 disabled across every reload.
LID_STATE_CONF="$HOME/.config/hypr/lid-state.conf"

lid_state_clear() {
  [ -s "$LID_STATE_CONF" ] || return 0
  grep -q '^monitor' "$LID_STATE_CONF" 2>/dev/null || return 0
  logger -t hypr-lid "apply: lid open -> clearing persisted eDP-1 disable"
  printf '%s\n' '# Written by scripts/battery-refresh-rate.sh. Empty means "lid open".' \
    > "$LID_STATE_CONF"
}

# Safety net for a stale lid-state.conf. That file is sourced by hyprland.conf,
# so if a session ever ends with the lid shut and the external display is gone
# by the next start, the config would disable eDP-1 with nothing to replace it.
# Zero monitors is the black screen with no way back from the keyboard that the
# lid-close guard exists to prevent -- so if we ever see it, undo it.
# monitor-guard.sh owns that restore; it also covers undocking a closed lid.
ensure_some_monitor() {
  "$(dirname "$0")/monitor-guard.sh" --once "$1"
}

lid_is_closed() {
  for state_file in /proc/acpi/button/lid/*/state; do
    [ -r "$state_file" ] || continue
    case "$(cat "$state_file")" in *closed*) return 0 ;; esac
  done
  return 1
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
  # Never resurrect the panel while the lid is shut. This loop also runs on
  # every upower poll (~30s, even with no state change), so without this guard
  # a lid-close played out as: lid-close.sh disables eDP-1 and Hyprland moves
  # its workspaces to the external display (correct), then within half a minute
  # this daemon re-enabled eDP-1 and Hyprland restored "the workspace this
  # monitor was on" -- dragging them back onto a dark, closed screen.
  # Both keywords below re-enable a disabled monitor, so both must be skipped.
  # Only the monitor work is skipped: hypridle still needs settling below, and
  # a closed lid on battery is precisely when it should be running.
  if edp_is_disabled && lid_is_closed; then
    :
  else
    # The lid is open (or the panel is already live), so the persisted disable
    # must go -- otherwise the next config reload would re-apply it.
    lid_state_clear

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
  fi

  # hypridle only needs settling on a real power-state change.
  if [ "$state" != "$LAST_APPLIED" ]; then
    case "$state" in
      ac)
        pkill -f "$HYPRIDLE_BATTERY_PAT" 2>/dev/null || true
        ;;
      battery)
        pgrep -f "$HYPRIDLE_BATTERY_PAT" >/dev/null 2>&1 ||
          setsid hypridle -c "$HYPRIDLE_BATTERY_CONF" </dev/null >/dev/null 2>&1 &
        ;;
    esac
    LAST_APPLIED="$state"
  fi
}

if [ "$1" = "--once" ]; then
  ensure_some_monitor "apply --once"
  apply
  exit 0
fi

ensure_some_monitor startup

while :; do
  apply
  upower --monitor 2>/dev/null | while IFS= read -r _line; do
    apply
  done
  sleep 5
done
