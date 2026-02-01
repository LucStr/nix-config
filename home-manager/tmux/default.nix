{ pkgs, lib, ... }:
let 
  fromGitHub = rev: ref: owner: repo: pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = repo;
      version = ref;
      rtpFilePath = "vim-tmux-navigator.tmux";
      src = builtins.fetchGit {
        url = "https://github.com/${owner}/${repo}.git";
        ref = ref;
        rev = rev;
     };
  };

in
{
  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      (fromGitHub "743f1e8057bf2404db137192bc2f81e993eb065d" "main" "kranich" "vim-tmux-navigator")
      catppuccin
    ];

    extraConfig = ''
      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1

      # Pane resizing
      bind -n C-M-h resize-pane -L 5
      bind -n C-M-j resize-pane -D 5
      bind -n C-M-k resize-pane -U 5
      bind -n C-M-l resize-pane -R 5

      # Create new window
      bind -n M-c new-window

      # Switch windows with Alt+1-9
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9
      bind -n M-0 select-window -t 10

      set -g @catppuccin_flavour 'mocha'

      setw -g mouse on
    '';
  };
}
