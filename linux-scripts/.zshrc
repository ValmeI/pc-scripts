# ----------------------------------------------
# Path to your oh-my-zsh installation
# ----------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# ----------------------------------------------
# Homebrew (ensures fastfetch is in PATH)
# ----------------------------------------------
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ----------------------------------------------
# Pyenv for multiple Python versions
# ----------------------------------------------
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# ----------------------------------------------
# Zoxide
# ----------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
eval "$(zoxide init zsh)"

# ----------------------------------------------
# Basic history settings
# ----------------------------------------------
setopt HIST_IGNORE_ALL_DUPS       # Ignore duplicates in history entirely
setopt HIST_SAVE_NO_DUPS          # Don’t save duplicate commands
setopt HIST_IGNORE_SPACE          # Ignore commands that start with a space
setopt HIST_FIND_NO_DUPS          # Don’t display duplicate commands in history search

# ----------------------------------------------
# Alias for fastfetch (ff) + run it (if not vscode)
# ----------------------------------------------
alias ff='fastfetch --config /home/valme/pc-scripts/fastfetch-config/config.jsonc'
if [ "$TERM_PROGRAM" != "vscode" ]; then
    ff
fi

# ----------------------------------------------
# Workaround for Ryzen 7 Pro 8840HS suspend
# ----------------------------------------------
alias sleep='echo freeze | sudo tee /sys/power/state'

# ----------------------------------------------
# GNOME keyring for SSH keys
# ----------------------------------------------
eval "$( /usr/bin/gnome-keyring-daemon --start --components=ssh > /dev/null 2>&1 )"
export SSH_AUTH_SOCK

# ----------------------------------------------
# AWS CLI in ~/.local/bin/aws
# ----------------------------------------------
export PATH="$HOME/.local/bin/aws:$PATH"

# ----------------------------------------------
# Common Aliases for Opening/Reloading Configs
# ----------------------------------------------
alias openzs='code ~/.zshrc'
alias openbs='code ~/.bashrc'
alias opengit='code ~/.gitconfig'
alias openssh='code ~/.ssh/config'
alias opencode='code ~/.config/Code/User/settings.json'
alias reloadzs='source ~/.zshrc'
alias reloadbs='source ~/.bashrc'
alias reloadgit='source ~/.gitconfig'
alias reloadssh='source ~/.ssh/config'
alias reloadcode='source ~/.config/Code/User/settings.json'

# ----------------------------------------------
# Other Aliases
# ----------------------------------------------
alias port='function _port() { sudo ss -tulnp | grep ":$1"; }; _port'
alias cd='z'  # Use zoxide
alias bat='batcat'
alias cat='bat --paging=never --plain'
alias grep='grep --color=auto'
alias wind='windsurf'
alias myip='curl ifconfig.me' # Get your public IP address
alias ..='cd ..'
alias c='clear'
alias nano='code'
alias py='python3'
alias pyvers='python3 --version'
alias bl='black --line-length 120 .'
export RUFF_CONFIG=~/pc-scripts/python-scripts/pyproject.toml
alias rr="rm -rf .ruff_cache && ruff check --fix . && ruff format ."
alias pipfreeze="pip freeze | grep -v 'types-requests' | grep -v 'black' | grep -v 'mypy' | grep -v 'icecream' >"
alias init='python3 ~/pc-scripts/python-scripts/generate_init.py'   # Creates __init__.py in all subdirs

# ----------------------------------------------
# Zsh autocompletion setup
# ----------------------------------------------
autoload -U compinit
compinit

# ----------------------------------------------
# More advanced history configuration
# ----------------------------------------------
HISTFILE=$HOME/.zhistory
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# ----------------------------------------------
# Keybindings for history substring search
# ----------------------------------------------
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ----------------------------------------------
# Never beep
# ----------------------------------------------
setopt NO_BEEP

# ----------------------------------------------
# Oh My Zsh + Theme + Plugins
# ----------------------------------------------
ZSH_THEME="agnoster"
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13
ENABLE_CORRECTION="true"

plugins=(
    git
    zsh-autosuggestions
    you-should-use
    history-substring-search
    zsh-syntax-highlighting
    command-not-found
    sudo
    gitfast
)

# ----------------------------------------------
# ZSH Syntax Highlighting + Autosuggestions
# ----------------------------------------------
source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ----------------------------------------------
# Finally, load Oh My Zsh
# ----------------------------------------------
source "$ZSH/oh-my-zsh.sh"

# ----------------------------------------------
# eza for ls
# ----------------------------------------------
alias ls='eza -A --icons --group-directories-first'
alias l='eza -lhAF --group-directories-first --icons --git'

# ----------------------------------------------
# Show how long each command took
# ----------------------------------------------
preexec() { timer=$(date +%s); }
precmd() {
    if [[ -n $timer ]]; then
        echo "Took $(( $(date +%s) - timer )) seconds"
    fi
}
