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
      NVM_DIR = "$HOME/.nvm";
    };
    sessionPath = [
      "$HOME/.nix-profile/bin"
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/.npm-global/bin"
      "$HOME/.spicetify"
      "$HOME/.local/share/JetBrains/Toolbox/scripts"
      "$HOME/.dotnet"
      "$HOME/.dotnet/tools"
    ];
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      cd = "z";
      k = "kubectl";
      tvim = "bash $HOME/.config/scripts/tvim.sh";
    };
    profileExtra = ''
      # Reset guard and re-source hm-session-vars to set PATH
      # (Guard may be inherited from parent, but /etc/profile.env resets PATH)
      unset __HM_SESS_VARS_SOURCED
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    '';
    initExtra = ''
      # NVM initialization (kept separate from nix)
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    '';
  };

  home.packages = with pkgs; [
    lazygit
    (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
    ]))
  ];

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
  }) [ "hypr" "waybar" "wofi" "gtk-3.0" "alacritty" "scripts" "gh-dash" ]);

  # Enable better integration for non-NixOS Linux
  targets.genericLinux.enable = true;

  home.stateVersion = "23.05";
}
