# Fix Microsoft Sculpt Keyboard Mapping on macOS

This guide will help you fix the keyboard mapping for the Microsoft Sculpt keyboard on macOS by changing the keyboard type from 43 to 41.

## Prerequisites

- Administrator privileges (sudo access)
- Microsoft Sculpt keyboard connected to your Mac

## Steps

### 1. Convert the plist to XML format

Open Terminal (use the regular Terminal app, not Ghostty) and run:

```bash
sudo plutil -convert xml1 /Library/Preferences/com.apple.keyboardtype.plist
```

This converts the binary plist file to XML format so you can edit it manually.

### 2. Edit the plist file

Open the plist file with a text editor that has sudo privileges:

```bash
sudo nano /Library/Preferences/com.apple.keyboardtype.plist
```

Or if you prefer using a GUI editor:

```bash
sudo open -a TextEdit /Library/Preferences/com.apple.keyboardtype.plist
```

### 3. Find and modify the keyboard mapping

Look for the Microsoft Sculpt keyboard entry:

```xml
<key>1957-1118-0</key>
<integer>43</integer>
```

Change the integer value from **43** to **41**:

```xml
<key>1957-1118-0</key>
<integer>41</integer>
```

### 4. Save the file

Save the file and exit the editor.

### 5. Reboot your Mac

Restart your Mac for the changes to take effect:

```bash
sudo reboot
```

## Verification

After rebooting, your Microsoft Sculpt keyboard should work correctly with the proper key mappings.

## Troubleshooting

- If the file doesn't exist, create it first or connect your Microsoft Sculpt keyboard and let macOS detect it
- If you don't see the `1957-1118-0` key, make sure your Microsoft Sculpt keyboard is connected
- If the changes don't take effect, try logging out and logging back in before rebooting

## Notes

- VendorID: 1957 (Microsoft)
- ProductID: 1118 (Sculpt keyboard)
- Keyboard type 41 provides the correct layout mapping for this keyboard
