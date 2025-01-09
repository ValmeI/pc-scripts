#!/bin/bash

# Step 1: Set x-terminal-emulator to Ghostty
echo "Configuring x-terminal-emulator to use Ghostty..."
sudo update-alternatives --config x-terminal-emulator

# Step 2: Update Cinnamon's default terminal to x-terminal-emulator
echo "Setting Cinnamon default terminal to x-terminal-emulator..."
gsettings set org.cinnamon.desktop.default-applications.terminal exec 'x-terminal-emulator'
gsettings set org.cinnamon.desktop.default-applications.terminal exec-arg ''

# Step 3: Verify the settings
echo "Verifying Cinnamon terminal settings..."
gsettings list-recursively org.cinnamon.desktop.default-applications.terminal

echo "Configuration complete. Restart Nemo for changes to take effect."
