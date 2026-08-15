#!/usr/bin/env bash

statefile="$HOME/.cache/wf-recorder-current-file"

if [ "$1" = "abort" ]; then
    if pgrep -f wf-recorder >/dev/null; then
        pkill -9 -f wf-recorder
        [ -f "$statefile" ] && rm -f "$(cat "$statefile")" "$statefile"
        notify-send "Recording aborted"
    fi
elif pgrep -f wf-recorder >/dev/null; then
    pkill -INT -f wf-recorder
    notify-send "Recording saved!"
else
    mkdir -p "$HOME/Videos/Recordings"

    filename="$HOME/Videos/Recordings/Recording from $(date '+%Y-%m-%d %H-%M-%S').mp4"
    echo "$filename" > "$statefile"

    wf-recorder \
        -f "$filename" \
        -c libx264 \
        -r 60 \
        -p pix_fmt=yuv420p \
        -p color_range=2 \
        -g "$(slurp)"
fi
