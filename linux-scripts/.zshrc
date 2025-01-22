setopt HIST_IGNORE_ALL_DUPS       # Ignore duplicates in history entirely
setopt HIST_SAVE_NO_DUPS          # Don’t save duplicate commands
setopt HIST_IGNORE_SPACE          # Ignore commands that start with a space
setopt HIST_FIND_NO_DUPS          # Don’t display duplicate commands in history search


# Alias for fastfetch with custom configuration
alias fastfetch='fastfetch --config /home/valme/pc-scripts/fastfetch-config/config.jsonc'
alias ff='fastfetch'

# Check if not running in VS Code terminal
if [ "$TERM_PROGRAM" != "vscode" ]; then
    fastfetch
fi

# workaround to get ryzen 7 pro 8840hs suspend working, so use freeze from command line
alias sleep='echo freeze | sudo tee /sys/power/state'


# To avoid ssh key password re-enter after restart
#eval $(/usr/bin/gnome-keyring-daemon --start --components=ssh)
#export SSH_AUTH_SOCK
# Start keychain and add the SSH key
#eval `keychain --eval --agents ssh ~/.ssh/linux-bitbucket-planet42`

# Start gnome-keyring and add SSH component and redirect the output to /dev/null:
eval $(/usr/bin/gnome-keyring-daemon --start --components=ssh > /dev/null 2>&1)
export SSH_AUTH_SOCK

# for aws cli
export PATH="$HOME/.local/bin/aws:$PATH"

# Common Aliases for Opening Configuration Files
alias openzs='code ~/.zshrc'
alias openbs='code ~/.bashrc'
alias opengit='code ~/.gitconfig'
alias openssh='code ~/.ssh/config'
alias opencode='code ~/.config/Code/User/settings.json'

# Common Aliases for Reloading Configuration Files
alias reloadzs='source ~/.zshrc'
alias reloadbs='source ~/.bashrc'
alias reloadgit='source ~/.gitconfig'
alias reloadssh='source ~/.ssh/config'
alias reloadcode='source ~/.config/Code/User/settings.json'


# other aliases
alias port='function _port() { sudo ss -tulnp | grep ":$1"; }; _port'
alias cd="z" # zoxide # populate all home dirs history to  "find "$HOME" -type d -print -exec zoxide add {} \; ""
alias bat='batcat'
alias cat='bat --paging=never --plain'
alias grep='grep --color=auto'
alias wind='windsurf'
alias myip='curl ifconfig.me' # Get your public IP address
alias ..='cd ..'
alias c='clear'
# alias m="mypy . --config-file '/home/ignar-valme-p42/Python Settings/mypy.ini'"
alias nano='code'
alias py='python3'
alias pyvers='python3 --version'
alias bl='black --line-length 120 .'
# alias vpn='./scripts/nordlayer_connect.sh'
# alias vpn_restart='sudo systemctl stop nordlayer.service && sudo systemctl start nordlayer.service'
alias pipfreeze="pip freeze | grep -v 'types-requests' | grep -v 'black' | grep -v 'mypy' | grep -v 'icecream' >"


#
# Finds all directories (-type d).
# For each directory, it checks if __init__.py already exists using [ ! -f ... ].
# If it doesn't exist, it creates the file using touch.
#
alias init="python3 ~/pc-scripts/python-scripts/generate_init.py"


# AUTOCOMPLETION

# initialize autocompletion
autoload -U compinit
compinit

# History configuration
HISTFILE=$HOME/.zhistory
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY              # Append history entries to the history file
setopt SHARE_HISTORY               # Share history between all sessions
setopt INC_APPEND_HISTORY          # Save each command to the history file as it is entered
setopt HIST_EXPIRE_DUPS_FIRST      # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS            # Do not record an entry that was just recorded again
setopt HIST_IGNORE_SPACE           # Do not record an entry starting with a space
setopt HIST_FIND_NO_DUPS           # Do not display a line previously found
setopt HIST_REDUCE_BLANKS          # Remove superfluous blanks before recording entry
setopt HIST_VERIFY                 # Show command with history expansion to user before running it
setopt EXTENDED_HISTORY            # Write timestamp info to history file

# Bind arrow keys for history substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# never beep
setopt NO_BEEP

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13


ENABLE_CORRECTION="true"


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions you-should-use history-substring-search zsh-syntax-highlighting command-not-found sudo gitfast)

# zsh-syntax-highlighting configuration (ensure it's loaded at the end)
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zsh-autosuggestions configuration
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

source $ZSH/oh-my-zsh.sh

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Pyenv for multiple python versions
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# for Zoxide
export PATH=$HOME/.local/bin:$PATH
eval "$(zoxide init zsh)"eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


# eza for ls end for no override
alias ls='eza -A --icons --group-directories-first'
alias l='eza -lhAF --group-directories-first --icons --git'


preexec() { timer=$(date +%s); }  # Hook that runs before each command
precmd() {                       # Hook that runs after each command
    if [[ -n $timer ]]; then
        echo "Took $(( $(date +%s) - timer )) seconds"
    fi
}
