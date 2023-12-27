# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    inputs.hyprland.homeManagerModules.default
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "luca";
    homeDirectory = "/home/luca";
    sessionVariables = {
      EDITOR = "nvim";
    };
 };
  
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      set number relativenumber
    '';
  };

  programs.bash.enable = true;
  programs.bash.shellAliases = {
    os-rebuild = "sudo nixos-rebuild switch --flake $HOME/nix-config/.#scorcher";
    home-rebuild = "home-manager switch --flake $HOME/nix-config/.#luca@scorcher";
    gt = "${pkgs.nodePackages_latest.graphite-cli}/bin/gt";
    gtt = "gt track -p main";
    gts = "gt submit -n";
    sail= "[ -f sail ] && ${pkgs.bash}/bin/bash sail || ${pkgs.bash}/bin/bash vendor/bin/sail";
    copy = "wl-copy > ";
  };

  home.file.".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home-manager/config/hypr";
  home.file.".config/waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home-manager/config/waybar";
  home.file.".config/wofi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home-manager/config/wofi";

  programs.bash.bashrcExtra = lib.mkMerge [
        (lib.mkBefore ''
          # goes before
	  PATH=$PATH:$HOME/.npm-global/bin/

	  alias ??='gh copilot suggest -t shell'
        '')
  ];


  
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
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
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
