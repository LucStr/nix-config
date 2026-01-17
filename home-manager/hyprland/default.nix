# Hyprland desktop environment module for standalone Home Manager
# This module provides the Hyprland configuration for non-NixOS systems (e.g., Void Linux)
{ inputs, config, pkgs, lib, ... }:

let
  # Helper script to set up D-Bus environment for Wayland
  # Note: On Void Linux, we don't use systemd, so this is simplified
  dbus-hyprland-environment = pkgs.writeShellScriptBin "dbus-hyprland-environment" ''
    dbus-update-activation-environment --all
    sleep 1
  '';

  # Helper script to configure GTK settings via gsettings
  configure-gtk = pkgs.writeShellScriptBin "configure-gtk" ''
    export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:$XDG_DATA_DIRS"
    gnome_schema=org.gnome.desktop.interface
    gsettings set $gnome_schema gtk-theme 'Everforest-Dark-BL'
    gsettings set $gnome_schema icon-theme 'Papirus-Dark'
    gsettings set $gnome_schema cursor-theme 'Adwaita'
  '';

  # Hyprland session wrapper script for SDDM
  # This ensures the Nix environment is properly set up before launching Hyprland
  start-hyprland = pkgs.writeShellScriptBin "start-hyprland" ''
    # Source Nix profile
    if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
      . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
    if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
      . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi

    # Set up environment for Home Manager
    if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi

    # Wayland-specific environment
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=Hyprland
    export XDG_SESSION_DESKTOP=Hyprland

    # NVIDIA-specific environment variables (for scorcher)
    export LIBVA_DRIVER_NAME=nvidia
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export NVD_BACKEND=direct
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    export WLR_NO_HARDWARE_CURSORS=1

    # GTK/Qt Wayland
    export GDK_BACKEND=wayland,x11
    export QT_QPA_PLATFORM=wayland;xcb
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export MOZ_ENABLE_WAYLAND=1

    # Set up D-Bus
    ${dbus-hyprland-environment}/bin/dbus-hyprland-environment

    # Launch Hyprland
    exec ${config.wayland.windowManager.hyprland.package}/bin/Hyprland
  '';
in
{
  imports = [
    ./packages.nix
  ];

  # Hyprland window manager (using flake package)
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    systemd.enable = false;  # Not using systemd on Void Linux
    xwayland.enable = true;
  };

  # Waybar
  programs.waybar = {
    enable = true;
    systemd.enable = false;  # Started via exec-once in hyprland.conf
  };

  # XDG Portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
    ];
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };

  # GTK theming
  gtk = {
    enable = true;
    theme = {
      name = "Everforest-Dark-BL";
      package = pkgs.everforest-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };

  # Cursor theme (for Wayland)
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Add helper scripts to PATH
  home.packages = [
    dbus-hyprland-environment
    configure-gtk
    start-hyprland
    pkgs.dconf  # Required for gsettings
    pkgs.glib   # For gsettings
  ];

  # Install start-hyprland to ~/.local/bin for SDDM
  home.file.".local/bin/start-hyprland" = {
    source = "${start-hyprland}/bin/start-hyprland";
    executable = true;
  };

  # Enable dconf for GTK settings
  dconf.enable = true;
}
