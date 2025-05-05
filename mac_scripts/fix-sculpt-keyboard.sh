#!/bin/bash

echo "Fixing Microsoft Sculpt keyboard mapping..."

# Create the .plist with correct mapping for VendorID 1957, ProductID 1118. "1957-1118-0" = 41; is the correct mapping rows that is important for example on US keyboard
sudo defaults write /Library/Preferences/com.apple.keyboardtype keyboardtype '{
    "1031-4176-0" = 40;
    "1957-1118-0" = 41;
    "50475-1133-0" = 40;
}'

# Ensure it's an XML file so you can inspect it later
sudo plutil -convert xml1 /Library/Preferences/com.apple.keyboardtype.plist

echo "Done. Please reboot to apply the fix."
