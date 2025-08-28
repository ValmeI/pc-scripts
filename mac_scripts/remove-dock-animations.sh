#!/usr/bin/env bash
set -euo pipefail

# remove-dock-animations.sh
# Make common macOS window and Dock animations effectively instant.

timestamp() { date -u +"%Y-%m-%d %H:%M:%S%z"; }
log() { printf "%s %s\n" "$(timestamp)" "$*"; }
info() { log "[INFO] $*"; }
warn() { log "[WARN] $*"; }
error() { log "[ERROR] $*"; }

trap 'error "Script failed at line $LINENO"; exit 1' ERR

info "Starting: make Dock and window animations faster/instant"

# 1) Kill most window animations system-wide
info "Disabling automatic window animations (NSAutomaticWindowAnimationsEnabled = false)"
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
info "Setting sheet/dialog resize/open/close time to near-instant (NSWindowResizeTime = 0.001)"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

info "Setting Dock minimize effect to 'scale' so windows pop open immediately"
defaults write com.apple.dock mineffect -string "scale"

info "Making Mission Control / Exposé animation as short as possible (expose-animation-duration = 0)"
defaults write com.apple.dock expose-animation-duration -float 0

info "Disabling app-launch animation from Dock (launchanim = false)"
defaults write com.apple.dock launchanim -bool false

info "Restarting Dock to apply changes"
if killall Dock 2>/dev/null; then
	info "Dock restarted successfully"
else
	warn "Failed to restart Dock with killall. Dock may restart automatically or a logout/login may be required."
fi

info "Done. Some apps may need a restart or a log out/in to pick up changes."
