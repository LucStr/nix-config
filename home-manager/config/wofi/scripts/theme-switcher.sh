#!/bin/bash

entries="Summer-Day\nSummer-Night"
source='source = ~/.config/hypr/themes/'
# delete-line="$(sed -i '1d' ~/.config/hypr/hyprland.conf)"


selected=$(echo -e $entries|wofi --dmenu '$2' --style .config/wofi/themes/$1.css --hide-scroll --cache-file /dev/null)

case $selected in
  Summer-Day)
    notify-send "Summer-Day"
    sed -i '1d' ~/.config/hypr/hyprland.conf
    sed -i '1i\source = ~/.config/hypr/themes/summer-day/summer-day.conf' ~/.config/hypr/hyprland.conf
    ;;
  Summer-Night)
    notify-send "Summer-Night"
    sed -i '1d' ~/.config/hypr/hyprland.conf
    sed -i '1i\source = ~/.config/hypr/themes/summer-night/summer-night.conf' ~/.config/hypr/hyprland.conf
    ;;
esac
