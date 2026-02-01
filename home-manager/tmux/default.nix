{ pkgs, lib, ... }:
{
  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      catppuccin
    ];

    extraConfig = ''
      # Use login shell to ensure home-manager sessionPath is available
      set -g default-command "bash --login"

      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1

      # Smart-splits integration for seamless nvim/tmux navigation and resizing
      # See: https://github.com/mrjones2014/smart-splits.nvim#tmux
      # Uses @pane-is-vim variable set by the plugin

      # Navigation (Ctrl + hjkl)
      bind-key -n C-h if -F "#{@pane-is-vim}" 'send-keys C-h' 'select-pane -L'
      bind-key -n C-j if -F "#{@pane-is-vim}" 'send-keys C-j' 'select-pane -D'
      bind-key -n C-k if -F "#{@pane-is-vim}" 'send-keys C-k' 'select-pane -U'
      bind-key -n C-l if -F "#{@pane-is-vim}" 'send-keys C-l' 'select-pane -R'

      # Resizing (Alt + hjkl)
      bind-key -n M-h if -F "#{@pane-is-vim}" 'send-keys M-h' 'resize-pane -L 3'
      bind-key -n M-j if -F "#{@pane-is-vim}" 'send-keys M-j' 'resize-pane -D 3'
      bind-key -n M-k if -F "#{@pane-is-vim}" 'send-keys M-k' 'resize-pane -U 3'
      bind-key -n M-l if -F "#{@pane-is-vim}" 'send-keys M-l' 'resize-pane -R 3'

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
