#!/bin/bash

# Step 1: Set x-terminal-emulator to Ghostty
echo "Configuring x-terminal-emulator to use Ghostty..."
sudo update-alternatives --config x-terminal-emulator

# Step 2: Update Nemo's default terminal to x-terminal-emulator
echo "Setting Nemo default terminal to x-terminal-emulator..."
gsettings set org.Nemo.desktop.default-applications.terminal exec 'x-terminal-emulator'
gsettings set org.Nemo.desktop.default-applications.terminal exec-arg ''

# Step 3: Verify the settings
echo "Verifying Nemo terminal settings..."
gsettings list-recursively org.Nemo.desktop.default-applications.terminal

echo "Configuration complete. Restart Nemo for changes to take effect."
