# Desktop packages for Hyprland on Void Linux
# These packages are normally provided by NixOS but need to be installed
# via home.packages when running standalone Home Manager
{ pkgs, ... }:

let
  nerdfonts = builtins.filter pkgs.lib.isDerivation (builtins.attrValues pkgs.nerd-fonts);
in
{
  home.packages = with pkgs; [
    # Terminal and launcher
    alacritty
    wofi

    # File manager
    nemo

    # Hyprland utilities
    hyprpaper
    hyprlock

    # Wayland utilities
    wl-clipboard
    cliphist
    wlr-randr
    grim
    slurp

    # System utilities
    brightnessctl
    jq
    xdg-utils

    # Notifications
    swaynotificationcenter

    # Themes
    goldy-plasma-theme
    everforest-theme

    # Fonts
    font-awesome
  ] ++ nerdfonts;

  # Install fonts to user directory
  fonts.fontconfig.enable = true;
}
