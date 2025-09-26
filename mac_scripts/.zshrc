# -----------------------------------------------
# Install Oh My Zsh if not already installed
# -----------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ----------------------------------------------
# Path to your Oh My Zsh installation
# ----------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# ----------------------------------------------
# Homebrew (macOS package manager) - Install if missing
# ----------------------------------------------
if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# ----------------------------------------------
# Zoxide (smart cd replacement) - Install if missing
# ----------------------------------------------
if ! command -v zoxide >/dev/null; then
    brew install zoxide
fi
eval "$(zoxide init zsh)"

# ----------------------------------------------
# Basic history settings
# ----------------------------------------------
setopt HIST_IGNORE_ALL_DUPS       # Ignore duplicates in history entirely
setopt HIST_SAVE_NO_DUPS          # Don’t save duplicate commands
setopt HIST_IGNORE_SPACE          # Ignore commands that start with a space
setopt HIST_FIND_NO_DUPS          # Don’t display duplicate commands in history search


# ----------------------------------------------
# Alias for fastfetch (ff) + run it (if not vscode) - Install if missing
# ----------------------------------------------
if ! command -v fastfetch >/dev/null; then
    brew install fastfetch
fi
alias ff='fastfetch --config ~/pc-scripts/fastfetch-config/config.jsonc'

if [ "$TERM_PROGRAM" != "vscode" ]; then
    ff
fi

# ----------------------------------------------
# AWS CLI in ~/.local/bin/aws
# ----------------------------------------------
export PATH="$HOME/.local/bin/aws:$PATH"

# ----------------------------------------------
# Common Aliases for Opening/Reloading Configs
# ----------------------------------------------
alias openzs='code ~/.zshrc'
alias activatevenv='source .venv/bin/activate'
alias opengit='code ~/.gitconfig'
alias openssh='code ~/.ssh/config'
alias opencode='code ~/Library/Application\ Support/Code/User/settings.json'
alias reloadzs='source ~/.zshrc'
alias reloadgit='source ~/.gitconfig'
alias reloadssh='source ~/.ssh/config'
alias reloadcode='source ~/Library/Application\ Support/Code/User/settings.json'

# ----------------------------------------------
# Other Aliases - Install tools if missing
# ----------------------------------------------
if ! command -v bat >/dev/null; then
    brew install bat
fi
if ! command -v eza >/dev/null; then
    brew install eza
fi
if ! command -v black >/dev/null; then
    brew install black
fi
if ! command -v speedtest-cli >/dev/null; then
    brew install speedtest-cli
fi

if ! brew list --cask | grep -q font-hack-nerd-font; then
    brew install --cask font-hack-nerd-font
fi

alias gc='git clone'
alias wind='windsurf'  # Open Windsurf (Alternative for VS Code)
alias cd='z'  # Use zoxide
alias cat='bat --paging=never --plain'
alias grep='grep --color=auto'
alias myip='curl ifconfig.me' # Get your public IP address
alias ..='cd ..'
alias c='clear'
alias nano='code'
alias py='python3'
alias pyvers='python3 --version'
alias blfull='black --line-length 150 .'
alias bl='black --line-length 150 --skip-string-normalization $(git diff --name-only --diff-filter=ACM | grep -E '\.py$') $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.py$')'
alias pipfreeze="pip freeze | grep -v 'typed-ast' | grep -v 'tomli' | grep -v 'types-requests' | grep -v 'black' | grep -v 'mypy' | grep -v 'icecream' | grep -v 'typing-inspection' > requirements.txt"
alias init='python3 ~/pc-scripts/python-scripts/generate_init.py'   # Creates __init__.py in all subdirs
alias dockfix='killall Dock'
alias speedtest='speedtest-cli'

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
# Java configuration (kept Corretto 17, removed AdoptOpenJDK)
# ----------------------------------------------
export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-17.jdk/Contents/Home

# ----------------------------------------------
# Oh My Zsh + Theme + Plugins
# ----------------------------------------------
#ZSH_THEME="agnoster"
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13
ENABLE_CORRECTION="true"

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Ensure plugin directory exists
mkdir -p "$ZSH_CUSTOM/plugins"

# Install missing plugins (runs once per session if missing)
if [[ -z "$ZSH_PLUGINS_INSTALLED" ]]; then
    if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
        git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
    fi
    if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
    fi
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    fi
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi
    if [ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ]; then
        git clone https://github.com/MichaelAquilina/zsh-you-should-use "$ZSH_CUSTOM/plugins/you-should-use"
    fi
    export ZSH_PLUGINS_INSTALLED=1
fi

plugins=(
    git
    zsh-autosuggestions
    history-substring-search
    command-not-found
    you-should-use
    sudo
    gitfast
    z
    macos
    fzf-tab
    fast-syntax-highlighting
    zsh-completions
)

# ----------------------------------------------
# Finally, load Oh My Zsh
# ----------------------------------------------
source "$ZSH/oh-my-zsh.sh"

# ----------------------------------------------
# Now init Starship (after oh-my-zsh) Theme with config - Install if missing
# ----------------------------------------------
if ! command -v starship >/dev/null; then
    brew install starship
fi
eval "$(starship init zsh)"
# Generate Starship config if not present
if [ ! -f ~/.config/starship.toml ]; then
    mkdir -p ~/.config
    starship preset catppuccin-powerline -o ~/.config/starship.toml
fi

# ----------------------------------------------
# eza for ls
# ----------------------------------------------
alias l='eza -A --icons --group-directories-first'
alias ls='eza -lhAF --group-directories-first --icons --git'

# ----------------------------------------------
# Show execution time only if >2 seconds
# ----------------------------------------------
preexec() { timer=$(date +%s); }
precmd() {
    if [[ -n $timer ]]; then
        duration=$(( $(date +%s) - timer ))
        if [[ $duration -gt 2 ]]; then
            echo "Took $duration seconds"
        fi
    fi
}

export HOMEBREW_NO_ENV_HINTS=1
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
#export DOCKER_HOST=unix://$HOME/.colima/default/docker.sock

# Added by Windsurf
export PATH="/Users/valme/.codeium/windsurf/bin:$PATH"

# ----------------------------------------------
# pyenv config
# ----------------------------------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# ----------------------------------------------
# direnv config for auto-loading .envrc files in folders
# ----------------------------------------------
eval "$(direnv hook zsh)"

# ----------------------------------------------
# Show venv in right prompt (after theme loads)
# ----------------------------------------------
RPROMPT='%{$fg[blue]%}$VENV_NAME%{$reset_color%}'

# ----------------------------------------------
# Git branch creation function with proper naming
# ----------------------------------------------
gsw_ticket() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: gsw_ticket <[type/]TICKET> <Title...>"
    echo "e.g.:  gsw_ticket feature/DE-901 DEV EMR cluster and refactor"
    return 1
  fi

  local raw_ticket="$1"
  shift
  local title="$*"

  # Split optional type and ticket key
  local type="" key="$raw_ticket"
  if [[ "$raw_ticket" == */* ]]; then
    type="${raw_ticket%%/*}"
    key="${raw_ticket#*/}"
  fi

  # Normalize: type lowercase, key uppercase
  if [[ -n "$type" ]]; then
    type=$(echo "$type" | tr '[:upper:]' '[:lower:]')
  fi
  key=$(echo "$key" | tr '[:lower:]' '[:upper:]')

  # Slugify title (lowercase, underscores)
  local slug_title
  slug_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/_/g; s/_+/_/g; s/^_|_$//g')

  # Compose branch name
  local branch
  if [[ -n "$type" ]]; then
    branch="${type}/${key}_${slug_title}"
  else
    branch="${key}_${slug_title}"
  fi

  git switch -c "$branch" && echo "→ Created and switched to branch: $branch"
}

# ----------------------------------------------
# Added by Windsurf
# ----------------------------------------------
export PATH="/Users/ignarvalme/.codeium/windsurf/bin:$PATH"

# ----------------------------------------------
# So Pyenv can find zlib and bzip2
# ----------------------------------------------
export LDFLAGS="-L$(brew --prefix zlib)/lib -L$(brew --prefix bzip2)/lib -L$(brew --prefix ncurses)/lib"
export CPPFLAGS="-I$(brew --prefix zlib)/include -I$(brew --prefix bzip2)/include -I$(brew --prefix ncurses)/include"
export PKG_CONFIG_PATH="$(brew --prefix zlib)/lib/pkgconfig:$(brew --prefix bzip2)/lib/pkgconfig:$(brew --prefix ncurses)/lib/pkgconfig"
export PATH="/opt/homebrew/opt/bzip2/bin:$PATH"
export PATH="/opt/homebrew/opt/ncurses/bin:$PATH"
