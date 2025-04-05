#!/bin/zsh

# Define colors for better visibility
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No color

log() {
    echo -e "$(date) - $1${NC}"
}

# ----------------------------------------------
# Remove macOS Bloatware
# ----------------------------------------------
log "${BLUE}Starting macOS bloatware removal...${NC}"

# List of bloatware apps to remove
BLOAT_APPS=(
    "GarageBand"
    "iMovie"
    "Keynote"
    "Numbers"
    "Pages"
    "Photo Booth"
    "Stocks"
    "Voice Memos"
    "News"
    "TV"
    "Music"
    "Podcasts"
    "Books"
)

for app in "${BLOAT_APPS[@]}"; do
    if [ -d "/Applications/$app.app" ]; then
        log "${YELLOW}Removing $app...${NC}"
        sudo rm -rf "/Applications/$app.app" && log "${GREEN}$app removed successfully.${NC}" || log "${RED}Failed to remove $app.${NC}"
    else
        log "${YELLOW}$app is not installed. Skipping...${NC}"
    fi
done

# ----------------------------------------------
# Final Steps
# ----------------------------------------------
log "${GREEN}Bloatware removal complete!${NC}"
