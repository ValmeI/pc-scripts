#!/bin/bash

# Define colors for better visibility
GREEN="\033[0;32m"   # Success messages
YELLOW="\033[0;33m"  # Warnings/skipped actions
RED="\033[0;31m"     # Errors/failures
BLUE="\033[0;34m"    # Info messages
NC="\033[0m"         # No color

log() {
    echo -e "$(date) - $1"
}

# Function to update Homebrew packages (without sudo)
update_homebrew() {
    log "${BLUE}Updating Homebrew...${NC}"
    if ! brew update; then
        log "${RED}Failed to update Homebrew. Another process might be running.${NC}"
        log "${YELLOW}If you're sure no other process is running, try: rm -f $(brew --prefix)/var/homebrew/lock${NC}"
        return 1
    fi

    log "${BLUE}Upgrading Homebrew packages...${NC}"
    if ! brew upgrade; then
        log "${RED}Failed to upgrade Homebrew packages.${NC}"
        return 1
    fi
    
    log "${GREEN}Homebrew update & upgrade completed successfully.${NC}"
}

# Function to update Mac App Store applications (without sudo)
update_mas_apps() {
    if command -v mas >/dev/null 2>&1; then
        log "${BLUE}Checking for Mac App Store updates...${NC}"
        mas upgrade && log "${GREEN}Mac App Store apps upgraded.${NC}" || log "${YELLOW}No updates available.${NC}"
    else
        log "${YELLOW}mas-cli not installed. Skipping Mac App Store updates.${NC}"
    fi
    echo ""
}

# Function to update applications that use Sparkle
update_sparkle_apps() {
    log "${BLUE}Checking for Sparkle-based applications...${NC}"
    
    sparkle_apps=$(mdfind "kMDItemCFBundleIdentifier == '*sparkle*'" 2>/dev/null)

    if [[ -n "$sparkle_apps" ]]; then
        log "${GREEN}Found Sparkle apps. Opening them to check for updates...${NC}"
        for app in $sparkle_apps; do
            log "${BLUE}Opening $app...${NC}"
            open -a "$app" &
        done
        wait  # Wait for all apps to be launched
    else
        log "${YELLOW}No Sparkle-based applications found.${NC}"
    fi
    echo ""
}

# Function to update system applications
update_system_apps() {
    log "${BLUE}Checking for macOS system updates...${NC}"
    
    # Download updates (installation requires sudo, but downloading does not)
    if softwareupdate --download --all; then
        log "${GREEN}macOS updates downloaded (installation requires manual approval).${NC}"
    else
        log "${YELLOW}No system updates available or failed to check.${NC}"
    fi
    echo ""
}

# Function to clean up old files
cleanup() {
    log "${BLUE}Cleaning up...${NC}"
    rm -rf ~/Downloads/*.dmg &  # Delete old installers in background
    brew cleanup &  # Run cleanup in parallel
    wait  # Wait for all cleanup tasks to complete
    log "${GREEN}Cleanup complete.${NC}"
    echo ""
}

# Function to run all application updates (used by update_apps_only.sh)
run_app_updates() {
    log "${BLUE}=== Starting application updates ===${NC}\n"
    
    update_homebrew
    update_mas_apps
    update_sparkle_apps
    cleanup
    
    log "${GREEN}=== All application updates and cleanup tasks are complete. ===${NC}"
}

# Function to run all updates including system (used by update_all.sh)
run_all_updates() {
    log "${BLUE}=== Starting full system updates ===${NC}\n"
    
    update_homebrew
    update_mas_apps
    update_system_apps
    update_sparkle_apps
    cleanup
    
    log "${GREEN}=== All updates and cleanup tasks are complete. ===${NC}"
}
