#!/bin/sh
export XCURSOR_SIZE=24

# Pick the primary display: any connected external (HDMI > DP > DVI > VGA),
# falling back to the internal panel. Scans /sys/class/drm so it works for any
# connector number (e.g. DP-12) without needing a hardcoded list.
#
# This script is sourced (not exec'd) so the export propagates to the caller.

export MAIN_DISPLAY="eDP-1"

hdmi=""; dp=""; dvi=""; vga=""
for status_file in /sys/class/drm/card*-*/status; do
  [ -f "$status_file" ] || continue
  [ "$(cat "$status_file")" = "connected" ] || continue

  connector=${status_file#/sys/class/drm/card*-}
  connector=${connector%/status}

  case "$connector" in
    eDP-*|Writeback-*) ;;
    HDMI-A-*) [ -z "$hdmi" ] && hdmi=$connector ;;
    DP-*)     [ -z "$dp" ]   && dp=$connector ;;
    DVI-D-*)  [ -z "$dvi" ]  && dvi=$connector ;;
    VGA-*)    [ -z "$vga" ]  && vga=$connector ;;
  esac
done

for candidate in "$hdmi" "$dp" "$dvi" "$vga"; do
  if [ -n "$candidate" ]; then
    export MAIN_DISPLAY="$candidate"
    break
  fi
done

echo "$MAIN_DISPLAY"
