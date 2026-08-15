#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="$HOME/.cache/waybar-unread-log.jsonl"

# "Unread" is simply: the rolling log has any entries. No count is tracked —
# the log is emptied on click (see waybar-notifications-clear.sh).
if [ -s "$LOG_FILE" ]; then
    text="󰂚"
    class="unread"
    tooltip=$(tail -n 10 "$LOG_FILE" | tac | jq -r 'select(.app != "") | "\(.app): \(.summary)"' 2>/dev/null || true)
else
    text=""
    class="none"
    tooltip=""
fi

jq -nc --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" \
    '{text: $text, tooltip: $tooltip, class: $class}'
