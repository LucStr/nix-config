{ config, pkgs, fetchFromGitHub, ... }:
{
  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      catppuccin
    ];

    extraConfig = ''
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R

      bind -n C-M-h resize-pane -L 5
      bind -n C-M-j resize-pane -D 5
      bind -n C-M-k resize-pane -U 5
      bind -n C-M-l resize-pane -R 5

      set -g @catppuccin_flavour 'mocha'
    '';
  };
}
