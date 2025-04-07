#!/bin/zsh

# Define colors for better visibility
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No color

log() {
    echo -e "$(date) - $1${NC}"
}

# ----------------------------------------------
# Show Hidden Files Permanently
# ----------------------------------------------
log "${BLUE}Making hidden files visible...${NC}"
defaults write com.apple.finder AppleShowAllFiles -bool True
killall Finder

# ----------------------------------------------
# Install Git and Clone Repository
# ----------------------------------------------
log "${BLUE}Installing Git...${NC}"
if ! command -v git &> /dev/null; then
    xcode-select --install
    log "${YELLOW}Git installation initiated. Follow the on-screen instructions.${NC}"
else
    log "${GREEN}Git is already installed.${NC}"
fi

log "${BLUE}Cloning pc-scripts repository...${NC}"
if [ -d "$HOME/pc-scripts/.git" ]; then
    log "${YELLOW}Repository already exists at $HOME/pc-scripts. Skipping clone.${NC}"
else
    git clone https://github.com/ValmeI/pc-scripts.git "$HOME/pc-scripts" || log "${RED}Failed to clone repository.${NC}"
fi

# ----------------------------------------------
# Install Homebrew and Run Brewfile
# ----------------------------------------------
log "${BLUE}Installing Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    log "${GREEN}Homebrew installed successfully.${NC}"
else
    log "${GREEN}Homebrew is already installed.${NC}"
fi

log "${BLUE}Running Brewfile...${NC}"
brew bundle --file="$HOME/pc-scripts/mac_scripts/Brewfile" || log "${RED}Failed to run Brewfile.${NC}"

# ----------------------------------------------
# Install Mac App Store Applications
# ----------------------------------------------
log "${BLUE}Installing Mac App Store applications...${NC}"

masfile="$HOME/pc-scripts/mac_scripts/Masfile"
if [ ! -f "$masfile" ]; then
    log "${RED}Masfile not found at $masfile. Skipping Mac App Store app installation.${NC}"
    exit 1
fi

while IFS= read -r line; do
    app_id=$(echo "$line" | awk '{print $1}')
    app_name=$(echo "$line" | sed "s/^[^#]*# *//; s/^ *//; s/ *$//")
    [[ "$app_id" =~ ^#.*$ || -z "$app_id" ]] && continue # Skip comments and empty lines

    log "${YELLOW}Checking if $app_name (ID: $app_id) is already installed...${NC}"

    if find "/Applications" -iname "$app_name.app" | grep -q .; then
        log "${GREEN}$app_name is already installed in /Applications. Skipping.${NC}"
    else
        log "${BLUE}Installing $app_name (ID: $app_id)...${NC}"
        mas install "$app_id" || log "${RED}Failed to install $app_name (ID: $app_id). Please check if the app name matches the real app name in /Applications.${NC}"
    fi

done < "$masfile"

log "${GREEN}Mac App Store applications installed successfully.${NC}"

# ----------------------------------------------
# Copy .zshrc to Home Directory
# ----------------------------------------------
log "${BLUE}Copying .zshrc to home directory...${NC}"
cp "$HOME/pc-scripts/mac_scripts/.zshrc" "$HOME/.zshrc" || log "${RED}Failed to copy .zshrc.${NC}"

# ----------------------------------------------
# Copy init.lua to Hammerspoon Directory
# ----------------------------------------------
log "${BLUE}Setting up Hammerspoon configuration...${NC}"
mkdir -p "$HOME/.hammerspoon"
cp "$HOME/pc-scripts/mac_scripts/init.lua" "$HOME/.hammerspoon/init.lua" || log "${RED}Failed to copy init.lua.${NC}"

# ----------------------------------------------
# Configure Ghostty
# ----------------------------------------------
log "${BLUE}Setting up Ghostty configuration...${NC}"
mkdir -p ~/.config/ghostty
cat <<EOL > ~/.config/ghostty/config
window-height = 50
window-width = 130
EOL

log "${BLUE}Reloading Ghostty...${NC}"
pkill -HUP ghostty || log "${YELLOW}Ghostty is not running, skipping reload.${NC}"

# ----------------------------------------------
# Make the setup script executable
# ----------------------------------------------
log "${BLUE}Making the setup script executable...${NC}"
chmod +x ~/pc-scripts/mac_scripts/new_macbook_setup.sh || log "${RED}Failed to make the script executable.${NC}"

# ----------------------------------------------
# Final Steps
# ----------------------------------------------
log "${GREEN}Setup complete! Please restart your terminal.${NC}"

# ----------------------------------------------
# Reload .zshrc Configuration
# ----------------------------------------------
log "${BLUE}Reloading shell configuration...${NC}"
if [ "$SHELL" != "/bin/zsh" ]; then
    log "${YELLOW}Switching to zsh shell to reload .zshrc...${NC}"
    /bin/zsh -c "source $HOME/.zshrc" || log "${RED}Failed to reload .zshrc in zsh.${NC}"
else
    source "$HOME/.zshrc" || log "${RED}Failed to reload .zshrc.${NC}"
fi
