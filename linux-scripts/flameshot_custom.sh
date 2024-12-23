#!/usr/bin/env sh

# Force the program to run with X11 and a specific screen scale factor
env QT_QPA_PLATFORM=xcb QT_SCREEN_SCALE_FACTORS="1.21" flameshot gui
