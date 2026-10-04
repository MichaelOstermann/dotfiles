set fish_greeting

starship init fish | source
fish_add_path "/home/michael/.bun/bin"
fish_add_path ~/.npm-global/bin

set -gx EDITOR nvim

alias cleanup ~/Development/dotfiles/scripts/arch-cleanup.sh
alias yt ~/Development/dotfiles/scripts/yt-music.sh

if status is-interactive
    # Ctrl+Backspace deletes up to the previous "/" instead of the whole path,
    # matching Ctrl+W's default behaviour.
    bind ctrl-backspace backward-kill-path-component
end
