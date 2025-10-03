#!/bin/bash
# filepath: /Users/valme/pc-scripts/mac_scripts/fix-sculpt-keyboard.sh

# Fix Microsoft Sculpt Keyboard Mapping on macOS
# Changes keyboard type from 43 to 41

set -e

PLIST_FILE="/Library/Preferences/com.apple.keyboardtype.plist"
BACKUP_FILE="/Library/Preferences/com.apple.keyboardtype.plist.backup"

echo "🔧 Fixing Microsoft Sculpt Keyboard Mapping..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)"
   exit 1
fi

# Create backup
echo "📦 Creating backup..."
cp "$PLIST_FILE" "$BACKUP_FILE"

# Convert to XML format
echo "🔄 Converting plist to XML format..."
plutil -convert xml1 "$PLIST_FILE"

# Use sed to replace the keyboard type
echo "✏️  Changing keyboard type from 43 to 41..."
sed -i '' '/<key>1957-1118-0<\/key>/{
n
s/<integer>43<\/integer>/<integer>41<\/integer>/
}' "$PLIST_FILE"

# Verify the change was made
if grep -A1 "1957-1118-0" "$PLIST_FILE" | grep -q "<integer>41</integer>"; then
    echo "✅ Successfully changed keyboard type to 41"
    echo "📄 Updated plist content:"
    grep -A1 "1957-1118-0" "$PLIST_FILE"
else
    echo "❌ Failed to update keyboard type"
    echo "🔄 Restoring backup..."
    cp "$BACKUP_FILE" "$PLIST_FILE"
    exit 1
fi

echo ""
echo "🔄 Please reboot your Mac for changes to take effect:"
echo "   sudo reboot"
echo ""
echo "💡 If issues persist, try:"
echo "   1. Disconnect and reconnect the keyboard"
echo "   2. Reset Bluetooth module: sudo pkill bluetoothd"
echo "   3. Clear keyboard cache: sudo rm -rf ~/Library/Preferences/ByHost/com.apple.HIToolbox.*"
