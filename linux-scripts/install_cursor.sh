#!/bin/bash

installCursor() {
    if ! [ -f /opt/cursor.appimage ]; then
        echo "Installing Cursor AI IDE..."

        # URLs for Cursor AppImage and Icon
        CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"
        ICON_URL="./linux-scripts/logos/cursor.png"

        # Paths for installation
        APPIMAGE_PATH="/opt/cursor.appimage"
        ICON_PATH="/opt/cursor.png"
        DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"

        # Install curl if not installed
        if ! command -v curl &> /dev/null; then
            echo "curl is not installed. Installing..."
            sudo apt-get update
            sudo apt-get install -y curl
        fi

        # Check if libfuse2 is already installed
        if ! dpkg -s libfuse2 &> /dev/null; then
            echo "libfuse2 is not installed. Installing..."
            sudo apt-get update && sudo apt-get install -y libfuse2
        fi

        # Download Cursor AppImage
        echo "Downloading Cursor AppImage..."
        sudo curl -L $CURSOR_URL -o $APPIMAGE_PATH
        sudo chmod +x $APPIMAGE_PATH

        # Download Cursor icon
        echo "Move Cursor icon..."
        sudo curl -L $ICON_URL -o $ICON_PATH

        # Create a .desktop entry for Cursor
        echo "Creating .desktop entry for Cursor..."
        sudo bash -c "cat > $DESKTOP_ENTRY_PATH" <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=$APPIMAGE_PATH --no-sandbox
Icon=$ICON_PATH
Type=Application
Categories=Development;
EOL

        echo "Cursor AI IDE installation complete. You can find it in your application menu."
    else
        echo "Cursor AI IDE is already installed."
    fi
}

installCursor