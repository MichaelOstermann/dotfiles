#!/usr/bin/env bash
set -euo pipefail

: >~/.cache/waybar-unread-log.jsonl

if [ "${1:-}" = "--dismiss" ]; then
    makoctl dismiss -a
fi
