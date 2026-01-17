# Home Manager configuration for Void Linux
# Entry point for standalone Home Manager on non-NixOS systems
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Shared modules (work on both NixOS and Void)
    ./nvim
    ./spicetify.nix
    ./tmux

    # Hyprland desktop environment (standalone, not using NixOS module)
    ./hyprland

    # Hyprland home-manager module from flake
    inputs.hyprland.homeManagerModules.default
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "luca";
    homeDirectory = "/home/luca";
    sessionVariables = {
      EDITOR = "nvim";

      # Wayland session variables
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      NIXOS_OZONE_WL = "1";

      # NVIDIA-specific (for scorcher)
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      WLR_NO_HARDWARE_CURSORS = "1";

      # GTK/Qt Wayland
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  programs.bash.enable = true;
  programs.bash.shellAliases = {
    # Updated alias for Void Linux
    home-rebuild = "home-manager switch --flake $HOME/nix-config/.#luca@void";

    # Keep other useful aliases
    gt = "${pkgs.nodePackages_latest.graphite-cli}/bin/gt";
    gtt = "gt track -p main";
    gts = "gt submit -n";
    sail = "[ -f sail ] && ${pkgs.bash}/bin/bash sail || ${pkgs.bash}/bin/bash vendor/bin/sail";
    copy = "wl-copy < ";
    cd = "z";
    docker-compose = "docker compose";
    k = "kubectl";
    tvim = "bash $HOME/.config/scripts/tvim.sh";
    code = "code";
  };

  # Symlink dotfiles from config directory
  home.file = let
    mkSymlink = name: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home-manager/config/${name}";
  in builtins.listToAttrs (map (name: {
    name = ".config/${name}";
    value.source = mkSymlink name;
  }) [ "hypr" "waybar" "wofi" "gtk-3.0" "alacritty" "scripts" ]);

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.bash.bashrcExtra = lib.mkMerge [
    (lib.mkBefore ''
      PATH=$PATH:$HOME/.npm-global/bin/:$HOME/.dotnet/tools:$HOME/.local/bin
      alias ??='gh copilot suggest -t shell'
    '')
  ];

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "LucStr";
    userEmail = "luca@nowhere.com";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "chromium.desktop";
      "x-scheme-handler/http" = "chromium.desktop";
      "x-scheme-handler/https" = "chromium.desktop";
      "x-scheme-handler/about" = "chromium.desktop";
      "x-scheme-handler/unknown" = "chromium.desktop";
      "x-scheme-handler/mongodb" = "mongodb-compass.desktop";
      "x-scheme-handler/mongodb+srv" = "mongodb-compass.desktop";
      "x-scheme-handler/vscode" = "code.desktop";
    };
  };

  # NOTE: Do NOT use systemd.user.startServices on Void Linux (uses runit, not systemd)
  # Daemons like waybar, swaync are started via exec-once in hyprland.conf

  home.stateVersion = "23.05";
}
