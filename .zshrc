eval "$(/opt/homebrew/bin/brew shellenv)"
source $(brew --prefix asdf)/libexec/asdf.sh
source $HOME/.zprezto/init.zsh
source $HOME/.zprezto/modules/directory/init.zsh
source $HOME/.zprezto/modules/completion/init.zsh
source $HOME/.zprezto/modules/history/init.zsh
source $HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.zprezto/modules/history-substring-search/init.zsh
source $HOME/zsh-autosuggestions/zsh-autosuggestions.zsh

WORDCHARS=${WORDCHARS/./}
# https://github.com/ajeetdsouza/zoxide/issues/491#issuecomment-1797118520
compdef __zoxide_z=vim; compdef __zoxide_zi=vim;

unsetopt BEEP
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

export EDITOR=nvim
export HOMEBREW_BUNDLE_FILE="$HOME/Development/dotfiles/Brewfile"
export PATH="/Users/michael/.bun/bin:$PATH"
export PATH="$(npm get prefix -g)/bin:$PATH"

function clear-completions() {
    rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcompdump"
    rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcompcache"
}

function format_size() {
    local b=$1
    if (( b < 1000 )); then
        echo "${b} B"
    elif (( b < 1000000 )); then
        printf "%.2f KB\n" "$(bc <<< "scale=2; $b/1000")"
    else
        printf "%.2f MB\n" "$(bc <<< "scale=2; $b/1000000")"
    fi
}

function bundle-size() {
    local bundle=$(bunx esbuild "$@" --minify)
    local min=$(echo "$bundle" | wc -c | xargs)
    local gzip=$(echo "$bundle" | gzip | wc -c | xargs)
    local brotli=$(echo "$bundle" | brotli | wc -c | xargs)
    echo "Min: $(format_size $min)"
    echo "Gzip: $(format_size $gzip) / $(bc <<< "($min - $gzip) * 100 / $min")%"
    echo "Brotli: $(format_size $brotli) / $(bc <<< "($min - $brotli) * 100 / $min")%"
}
