#!/usr/bin/env bash
SESSION=$(basename $PWD)
if tmux has-session -t $SESSION 2>/dev/null; then
    tmux attach -t $SESSION
else
    tmux new-session -s $SESSION vim .
fi
