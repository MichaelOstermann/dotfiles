#!/usr/bin/env bash
set -euo pipefail

updates=$(checkupdates 2>/dev/null || true)

if [ -z "$updates" ]; then
    exit 0
fi

jq -nc --arg tooltip "$updates" '{alt: "has-updates", tooltip: $tooltip}'
