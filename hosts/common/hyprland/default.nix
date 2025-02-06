{ inputs, lib, pkgs, username, ... }: 
let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };

  nerdfonts = builtins.filter pkgs.lib.isDerivation (builtins.attrValues pkgs.nerd-fonts);
in
{ 
  users.users.${username}.packages = with pkgs; [
    alacritty
    wofi
    nemo
    gvfs
    hyprpaper
    hyprlock
    jq
    wl-clipboard
    cliphist
    wlr-randr
    xdg-utils
    grim
    slurp
    brightnessctl
    goldy-plasma-theme
    configure-gtk
    dbus-sway-environment
    everforest-theme
    swaynotificationcenter
  ];

  # hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    #portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;

  };

  # waybar
  programs.waybar.enable = true;

   # xdg portal
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

   # auto login
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin = {
      enable = true;
      user = "luca";
    };
  };


  fonts.packages = [
    pkgs.font-awesome
  ] ++ nerdfonts;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  programs.seahorse.enable = true;
  programs.dconf.enable = true;
}
