#!/bin/bash

echo "🧹 Resetting keyboard and Bluetooth caches..."

# Reset Bluetooth
echo "🔄 Resetting Bluetooth module..."
sudo pkill bluetoothd

# Clear HIToolbox cache
echo "🗑️  Clearing HIToolbox cache..."
rm -rf ~/Library/Preferences/ByHost/com.apple.HIToolbox.*

# Clear keyboard input source cache
echo "🗑️  Clearing input source cache..."
sudo rm -rf /Library/Caches/com.apple.IntlDataCache*

echo "✅ Cache cleared. Please reboot your Mac."
