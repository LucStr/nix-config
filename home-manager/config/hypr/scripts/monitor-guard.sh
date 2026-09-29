#!/bin/sh
# Never let Hyprland run with zero monitors.
#
# lid-close.sh disables eDP-1 while an external display is attached. If that
# display then goes away with the lid still shut (undocking a closed laptop),
# nothing brought eDP-1 back: Hyprland was left with no outputs at all, and
# elogind -- now undocked with the lid closed -- suspended ~180 ms later.
# That suspend never came back; the panel stayed black on lid open and only a
# reboot helped. /var/log/suspend-debug.log shows it every time: a Thunderbolt
# "device disconnected", then "Suspending...", "monitors: []", and no "post"
# entry. Undocking with eDP-1 still enabled resumed fine.
#
# Usage:
#   monitor-guard.sh         daemon (exec-once): restore eDP-1 as soon as the
#                            last monitor is removed
#   monitor-guard.sh --once  check once, restore if needed, and wait for eDP-1
#                            to come up. Used by battery-refresh-rate.sh and by
#                            the elogind pre-sleep hook (system-sleep/), which
#                            closes the race against that immediate suspend.

LID_STATE_CONF="$HOME/.config/hypr/lid-state.conf"
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

edp_is_enabled() {
  hyprctl -j monitors 2>/dev/null | jq -e 'any(.[]; .name == "eDP-1")' >/dev/null 2>&1
}

# $1: short reason for the log.
restore_if_empty() {
  # hyprctl -j monitors lists only ENABLED monitors.
  count=$(hyprctl -j monitors 2>/dev/null | jq -r 'length' 2>/dev/null)
  # If hyprctl or jq failed we cannot tell; do nothing rather than guess.
  case "$count" in ''|*[!0-9]*) return 0 ;; esac
  [ "$count" -eq 0 ] || return 0

  logger -t hypr-lid "$1: no monitors left -> clearing lid state, reloading"
  # Clearing the persisted disable is what re-enables eDP-1: the reload below
  # then applies the plain eDP-1 rule from hyprland.conf.
  #
  # It has to be a reload. With no monitors Hyprland is in its "unsafe state"
  # and silently ignores `hyprctl keyword monitor ...`: it answers "ok", logs
  # the keyword, and never applies the rule (verified on 0.55.4 -- the old
  # keyword-based restore here never brought the panel back).
  printf '%s\n' '# Cleared by scripts/monitor-guard.sh (no monitors).' \
    > "$LID_STATE_CONF"
  hyprctl reload >/dev/null

  # Wait for the panel to be live. The pre-sleep hook depends on this: it must
  # not return, and let the kernel suspend, while eDP-1 is still coming up.
  i=0
  while [ "$i" -lt 30 ]; do
    edp_is_enabled && return 0
    sleep 0.1
    i=$((i + 1))
  done
  logger -t hypr-lid "$1: eDP-1 still not enabled after 3s"
}

if [ "$1" = "--once" ]; then
  restore_if_empty "${2:-check}"
  exit 0
fi

# Hyprland's event socket; reconnect if it drops, exit once Hyprland is gone.
while [ -S "$SOCK" ]; do
  nc -U -d "$SOCK" 2>/dev/null | while IFS= read -r line; do
    case "$line" in
      'monitorremoved>>'*) restore_if_empty "removed ${line#monitorremoved>>}" ;;
    esac
  done
  sleep 1
done
