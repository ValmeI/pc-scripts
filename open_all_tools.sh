#!/bin/bash

# Open DBeaver
snap run dbeaver-ce &

# Open Visual Studio Code
code &

# Open Chrome P42 Work profile
google-chrome --profile-directory="Profile 1" &

# Open Chrome Personal profile
google-chrome --profile-directory="Default" &

# Open Terminal
gnome-terminal &

# Open nemo files explorer
nemo &