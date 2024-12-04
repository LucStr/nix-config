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
      bind -n C-M-h resize-pane -L 5
      bind -n C-M-j resize-pane -D 5
      bind -n C-M-k resize-pane -U 5
      bind -n C-M-l resize-pane -R 5

      set -g @catppuccin_flavour 'mocha'

      setw -g mouse on
    '';
  };
}
