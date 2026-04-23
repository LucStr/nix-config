#!/usr/bin/env bash
SESSION=$(basename $PWD)
if tmux has-session -t $SESSION 2>/dev/null; then
    tmux attach -t $SESSION
else
    tmux new-session -d -s $SESSION vim .
    tmux split-window -t $SESSION:1 -v -p 25
    tmux select-pane -t $SESSION:1.1
    tmux new-window -t $SESSION -n git 'lazygit'
    tmux new-window -t $SESSION -n dash 'gh dash'
    tmux select-window -t $SESSION:1
    tmux attach -t $SESSION
fi
