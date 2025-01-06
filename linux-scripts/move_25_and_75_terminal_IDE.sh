#!/bin/bash

# Launch ghostty terminal
/usr/bin/ghostty &
sleep 1  # Allow time for the terminal to open

# Move ghostty to the left 25% of the screen
wmctrl -r ghostty -e 0,0,0,640,-1

# Launch windsurf IDE
windsurf &
sleep 2  # Allow time for the IDE to open

# Move windsurf to the right 75% of the screen
wmctrl -r windsurf -e 0,640,0,1920,-1
