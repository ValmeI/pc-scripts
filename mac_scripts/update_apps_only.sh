#!/bin/bash

# Function to update Homebrew (without sudo)
update_homebrew() {
    echo "Updating Homebrew..."
    brew update

    echo "Upgrading Homebrew packages..."
    brew upgrade

    echo "Cleaning up Homebrew..."
    brew cleanup
}

# Function to update Mac App Store applications (requires sudo)
update_mas_apps() {
    if command -v mas >/dev/null 2>&1; then
        echo "Updating Mac App Store applications..."
        mas upgrade
    else
        echo "mas-cli not installed. Skipping Mac App Store updates."
    fi
}

# Function to update applications that use Sparkle (using GUI approach)
update_sparkle_apps() {
    # Check if Sparkle Test App is installed in /Applications
    if [ -d "/Applications/Sparkle Test App.app" ]; then
        echo "Opening Sparkle Test App to update Sparkle-based applications..."
        open -a "/Applications/Sparkle Test App.app"
    else
        echo "Sparkle Test App not found in /Applications. Skipping Sparkle updates."
    fi
}

# Function to perform cleanup
cleanup() {
    echo "Performing cleanup..."
    rm -rf ~/Downloads/*.dmg
    brew cleanup
    echo "Application update and cleanup complete."
}

# Run Homebrew updates without sudo
update_homebrew

# Run other updates with sudo as necessary
sudo bash <<EOF
$(typeset -f update_mas_apps)

update_mas_apps
EOF

# Update Sparkle applications without sudo (GUI)
update_sparkle_apps

# Perform cleanup without sudo
cleanup

echo "All application updates and cleanup tasks are complete."