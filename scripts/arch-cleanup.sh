#!/usr/bin/env bash
# Arch housekeeping. Each step shows what it would free and asks first.
#
#   pacman cache    keep the two newest versions, drop uninstalled packages
#   orphans         packages nothing depends on any more
#   ~/.cache        files not touched for 30 days
#   journal         logs older than a week
#   mirrors         re-rank the mirror list
set -uo pipefail

bold=$(tput bold 2>/dev/null) dim=$(tput dim 2>/dev/null) reset=$(tput sgr0 2>/dev/null)

step() { printf '\n%s%s%s\n' "$bold" "$1" "$reset"; }
note() { printf '%s%s%s\n' "$dim" "$1" "$reset"; }
ask() {
    local answer
    read -rp "$1 [y/N] " answer
    [[ $answer == [yY]* ]]
}

step "Pacman cache"
note "$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1) in /var/cache/pacman/pkg"
paccache -dk2 | tail -n 1
paccache -duk0 | tail -n 1
if ask "Trim it?"; then
    sudo paccache -rk2
    sudo paccache -ruk0
fi

step "Orphaned packages"
orphans=$(paru -Qdtq 2>/dev/null)
if [ -z "$orphans" ]; then
    note "None."
else
    echo "$orphans" | column -c "$(tput cols 2>/dev/null || echo 80)"
    # shellcheck disable=SC2086
    ask "Remove them?" && sudo pacman -Rns $orphans
fi

step "~/.cache"
stale=$(find ~/.cache -type f -mtime +30 -printf '%s\n' 2>/dev/null | awk '{ n++; s += $1 } END { printf "%d files, %.0f MB", n, s / 1e6 }')
note "$stale not touched for 30 days"
if ask "Delete them?"; then
    find ~/.cache -type f -mtime +30 -delete
    find ~/.cache -type d -empty -delete
fi

step "Journal"
note "$(journalctl --disk-usage 2>/dev/null)"
if ask "Drop logs older than 7 days?"; then
    sudo journalctl --rotate
    sudo journalctl --vacuum-time=7d
fi

step "Mirrors"
if command -v reflector >/dev/null; then
    ask "Re-rank the mirror list?" && sudo reflector --country Austria,Germany --protocol https --age 12 \
        --sort rate --number 20 --save /etc/pacman.d/mirrorlist
else
    note "reflector is not installed."
fi
