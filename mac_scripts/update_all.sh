#!/bin/bash

# Define colors for better visibility
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No color

log() {
    echo -e "$(date) - $1"
}

# Function to update Homebrew packages (without sudo)
update_homebrew() {
    log "${BLUE}Updating Homebrew...${NC}"
    brew update &  # Run update in background

    log "${BLUE}Upgrading Homebrew packages...${NC}"
    brew upgrade &  # Run upgrade in parallel

    wait  # Ensure all Homebrew updates finish
    log "${GREEN}Homebrew update & upgrade completed.${NC}"
}

# Function to update Mac App Store applications (without sudo)
update_mas_apps() {
    if command -v mas >/dev/null 2>&1; then
        log "${BLUE}Checking for Mac App Store updates...${NC}"
        mas upgrade && log "${GREEN}Mac App Store apps upgraded.${NC}" || log "${YELLOW}No updates available.${NC}"
    else
        log "${YELLOW}mas-cli not installed. Skipping Mac App Store updates.${NC}"
    fi
}

# Function to check for system updates (without sudo)
update_system_apps() {
    log "${BLUE}Checking for macOS system updates...${NC}"
    
    # Download updates (installation requires sudo, but downloading does not)
    softwareupdate --download --all && log "${GREEN}macOS updates downloaded (installation requires manual approval).${NC}" || log "${YELLOW}No system updates available.${NC}"
}

# Function to update applications that use Sparkle
update_sparkle_apps() {
    log "${BLUE}Checking for Sparkle-based applications...${NC}"

    # Optimized search for Sparkle-based apps
    sparkle_apps=$(mdfind "kMDItemCFBundleIdentifier == '*sparkle*'" 2>/dev/null)

    if [[ -n "$sparkle_apps" ]]; then
        log "${GREEN}Found Sparkle apps. Opening them to check for updates...${NC}"
        for app in $sparkle_apps; do
            log "${BLUE}Opening $app...${NC}"
            open -a "$app" &
        done
        wait  # Ensure all are launched before continuing
    else
        log "${YELLOW}No Sparkle-based applications found.${NC}"
    fi
}

# Function to clean up old files, running cleanup tasks in parallel
cleanup() {
    log "${BLUE}Performing cleanup...${NC}"

    rm -rf ~/Downloads/*.dmg &  # Delete old installers in background
    brew cleanup &  # Run cleanup in parallel
    
    wait  # Wait for all cleanup tasks to complete
    log "${GREEN}Cleanup complete.${NC}"
}

# Run updates in parallel for better speed
update_homebrew &
update_mas_apps &
update_system_apps &
update_sparkle_apps &

wait  # Ensure all update processes complete before cleanup
cleanup

log "${GREEN}All updates and cleanup tasks are complete.${NC}"
