#!/bin/bash

echo "Fixing Microsoft Sculpt keyboard mapping..."

# Define the plist file path
PLIST_PATH="/Library/Preferences/com.apple.keyboardtype.plist"

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Create the .plist with correct mapping for VendorID 1957, ProductID 1118
echo "Updating keyboard mapping in $PLIST_PATH..."
sudo defaults write /Library/Preferences/com.apple.keyboardtype keyboardtype '{
    "1031-4176-0" = 40;  # Example mapping for another keyboard
    "1957-1118-0" = 41;  # Microsoft Sculpt keyboard mapping
    "50475-1133-0" = 40; # Example mapping for another keyboard
}'

# Ensure the file is converted to XML format for inspection
echo "Converting $PLIST_PATH to XML format..."
sudo plutil -convert xml1 "$PLIST_PATH"

# Verify if the changes were applied successfully
if [[ $? -eq 0 ]]; then
    echo "Keyboard mapping updated successfully. Please reboot to apply the fix."
else
    echo "Failed to update keyboard mapping. Please check the script and try again."
    exit 1
fi
