# Home Manager configuration for Gentoo Linux
{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    ./nvim   # Neovim with all plugins
    ./tmux   # Tmux with plugins (for tvim)
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
    config.allowUnfree = true;
  };

  home = {
    username = "luca";
    homeDirectory = "/home/luca";
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      cd = "z";
      k = "kubectl";
      tvim = "bash $HOME/.config/scripts/tvim.sh";
    };
    bashrcExtra = ''
      PATH=$PATH:$HOME/.local/bin:$HOME/.npm-global/bin
    '';
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/luca/nix-config";
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.gh = {
    enable = true;
    extensions = with pkgs; [ gh-dash ];
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "LucStr";
      user.email = "25279790+LucStr@users.noreply.github.com";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  # Symlink dotfiles from config directory
  home.file = let
    mkSymlink = name: config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix-config/home-manager/config/${name}";
  in builtins.listToAttrs (map (name: {
    name = ".config/${name}";
    value.source = mkSymlink name;
  }) [ "hypr" "waybar" "wofi" "gtk-3.0" "alacritty" "scripts" ]);

  home.stateVersion = "23.05";
}
