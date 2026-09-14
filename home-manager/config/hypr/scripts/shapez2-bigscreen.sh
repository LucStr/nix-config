#!/usr/bin/env bash
# Launch shapez 2 on the Dell ultrawide only.
#
# shapez 2 (Unity) under XWayland enumerates only ONE display and clamps the game to
# it. With both panels enabled, Unity picks the laptop eDP (2560 wide), so the in-game
# "Target Display" lists only eDP-1 and the game can never use the Dell or fill its
# 3440px width. Fix: blank the eDP for the lifetime of the game so the Dell is the sole
# display Unity sees. The eDP is restored on exit even if the game crashes (trap).
#
# Wired into Steam via launch options:
#   /home/luca/.config/hypr/scripts/shapez2-bigscreen.sh %command% -screen-fullscreen 0
# (-screen-fullscreen 0 keeps it borderless-windowed; exclusive fullscreen SIGSEGVs RADV.)

EDP_RULE="eDP-1,2560x1600@240,3440x0,1.25"   # must match the eDP line in hyprland.conf

restore() { hyprctl keyword monitor "$EDP_RULE" >/dev/null 2>&1; }
trap restore EXIT INT TERM

hyprctl keyword monitor "eDP-1,disable" >/dev/null 2>&1
"$@"            # run the game; do NOT exec, so the trap restores the eDP afterwards
