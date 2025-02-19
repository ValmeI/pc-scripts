#!/bin/bash

# Open DBeaver
open -na "DBeaver"

# Open Windsurf (Alternative for VS Code)
open -na "Windsurf"

# Open Chrome Personal Profile (Profile 1)
open -na "Google Chrome" --args --profile-directory="Profile 1"

# Open Chrome Work Profile (Default)
open -na "Google Chrome" --args --profile-directory="Default"

# Open Terminal Ghostty with "t" command for multiple tabs on start
open -na "Ghostty"
sleep 1
osascript -e 'tell application "System Events" to keystroke "t" using command down'

# Open Slack
open -na "Slack"

# Open Finder 
open -na "Finder"
