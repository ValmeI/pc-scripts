#!/bin/bash

# Define colors
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m" # For "No Change"
NC="\033[0m" # No color

# Log directory and file setup
LOGDIR="./valme_system_update/script_logs"
LOGFILE="$LOGDIR/$(date +%Y%m%d_%H%M%S)_update.log"
TIMESHIFT_CMD="timeshift"
APT_CMD="apt-get"
SNAP_CMD="snap"
FLATPAK_CMD="flatpak"
FWUPD_CMD="fwupdmgr"

# Ensure log directory exists
mkdir -p "$LOGDIR"

# Trap signals to ensure cleanup
trap 'echo -e "$(date) - ${RED}Script interrupted.${NC}" | tee -a "$LOGFILE"; exit 1' INT TERM

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "$(date) - ${RED}Please run as root${NC}" | tee -a "$LOGFILE"
  exit 1
fi

# Check if nala is installed; if so, use it instead of apt-get
if command -v nala &> /dev/null; then
  APT_CMD="nala"
  echo -e "$(date) - ${YELLOW}Using nala for package updates.${NC}" | tee -a "$LOGFILE"
else
  echo -e "$(date) - ${YELLOW}Nala not found, falling back to apt-get.${NC}" | tee -a "$LOGFILE"
fi

# Ensure essential commands are available
for cmd in "$TIMESHIFT_CMD" "$SNAP_CMD" "$FLATPAK_CMD" "$FWUPD_CMD"; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "$(date) - ${RED}Command $cmd is not available. Trying to install with $APT_CMD...${NC}" | tee -a "$LOGFILE"
    sudo "$APT_CMD" install "$cmd" -y || { 
      echo -e "$(date) - ${RED}Failed to install $cmd with $APT_CMD. Attempting with apt-get...${NC}" | tee -a "$LOGFILE"
      sudo apt-get install "$cmd" -y || { echo -e "${RED}Failed to install $cmd${NC}"; exit 1; }
    }
  fi
done

# Fix dpkg if interrupted
echo -e "$(date) - ${YELLOW}Checking for dpkg issues...${NC}" | tee -a "$LOGFILE"
sudo dpkg --configure -a

# Check for other package managers running
if sudo fuser /var/lib/dpkg/lock-frontend &>/dev/null || sudo fuser /var/lib/dpkg/lock &>/dev/null; then
  echo -e "$(date) - ${RED}Another package manager is running. Please close it and try again.${NC}" | tee -a "$LOGFILE"
  exit 1
fi

# Perform a Timeshift backup
echo -e "$(date) - ${YELLOW}Creating a Timeshift backup...${NC}" | tee -a "$LOGFILE"
sudo "$TIMESHIFT_CMD" --create --comments "Backup before system update" 2>>"$LOGFILE" | tee -a "$LOGFILE"

# Retain only the latest 3 Timeshift snapshots
echo -e "$(date) - ${YELLOW}Ensuring only the latest 3 Timeshift snapshots are retained...${NC}" | tee -a "$LOGFILE"
SNAPSHOTS_DIR="/timeshift/snapshots"
SNAPSHOTS_COUNT=$(ls -1 "$SNAPSHOTS_DIR" 2>/dev/null | wc -l)

if [ "$SNAPSHOTS_COUNT" -gt 3 ]; then
  SNAPSHOTS_TO_DELETE=$((SNAPSHOTS_COUNT - 3))
  echo -e "$(date) - ${YELLOW}Deleting the oldest $SNAPSHOTS_TO_DELETE snapshots...${NC}" | tee -a "$LOGFILE"
  ls -1t "$SNAPSHOTS_DIR" | tail -n "$SNAPSHOTS_TO_DELETE" | while read -r snapshot; do
    sudo rm -rf "$SNAPSHOTS_DIR/$snapshot"
    echo -e "$(date) - ${GREEN}Deleted snapshot: $snapshot${NC}" | tee -a "$LOGFILE"
  done
else
  echo -e "$(date) - ${BLUE}No Change: 3 or fewer snapshots present; no deletion necessary.${NC}" | tee -a "$LOGFILE"
fi

# Check for internet connectivity
if ! ping -c 1 google.com &> /dev/null; then
  echo -e "$(date) - ${RED}No internet connection. Please check your network settings.${NC}" | tee -a "$LOGFILE"
  exit 1
fi

# Check for disk space (ensure at least 2GB free space)
FREE_SPACE=$(df / | tail -1 | awk '{print $4}')
if [ "$FREE_SPACE" -lt 2097152 ]; then
  echo -e "$(date) - ${RED}Not enough disk space. At least 2GB free space is required.${NC}" | tee -a "$LOGFILE"
  exit 1
fi

# Update package list
echo -e "$(date) - ${YELLOW}Updating package list with $APT_CMD...${NC}" | tee -a "$LOGFILE"
sudo "$APT_CMD" update | tee -a "$LOGFILE"

# Check for package upgrades
echo -e "$(date) - ${YELLOW}Checking for package upgrades...${NC}" | tee -a "$LOGFILE"
UPGRADE_LIST=$(apt list --upgradable 2>/dev/null | tail -n +2 | awk -F/ '{print $1}')

if [ -z "$UPGRADE_LIST" ]; then
  echo -e "$(date) - ${BLUE}No Change: No packages need upgrading.${NC}" | tee -a "$LOGFILE"
else
  echo -e "$(date) - ${GREEN}The following packages will be upgraded:${NC}" | tee -a "$LOGFILE"
  echo "$(date) - $UPGRADE_LIST" | tee -a "$LOGFILE"
fi

# Upgrade packages
echo -e "$(date) - ${YELLOW}Upgrading packages with $APT_CMD...${NC}" | tee -a "$LOGFILE"
sudo "$APT_CMD" upgrade -y | tee -a "$LOGFILE"

# Perform full upgrade (includes package removals and new dependencies)
echo -e "$(date) - ${YELLOW}Performing full upgrade...${NC}" | tee -a "$LOGFILE"
sudo "$APT_CMD" full-upgrade -y | tee -a "$LOGFILE"

# Remove unnecessary packages
echo -e "$(date) - ${YELLOW}Removing unnecessary packages...${NC}" | tee -a "$LOGFILE"
sudo "$APT_CMD" autoremove -y | tee -a "$LOGFILE"

# Clean up .deb files of packages that are no longer installed
if [ "$APT_CMD" = "apt-get" ]; then
  echo -e "$(date) - ${YELLOW}Cleaning up .deb files of packages that are no longer installed...${NC}" | tee -a "$LOGFILE"
  sudo "$APT_CMD" autoclean -y | tee -a "$LOGFILE"
fi

# Check for Snap package updates
echo -e "$(date) - ${YELLOW}Checking for Snap package updates...${NC}" | tee -a "$LOGFILE"
SNAP_UPGRADE_LIST=$(sudo "$SNAP_CMD" refresh --list | tail -n +2)

if [ -z "$SNAP_UPGRADE_LIST" ]; then
  echo -e "$(date) - ${BLUE}No Change: All Snap packages are up to date.${NC}" | tee -a "$LOGFILE"
else
  echo -e "$(date) - ${GREEN}The following Snap packages will be upgraded:${NC}" | tee -a "$LOGFILE"
  echo "$(date) - $SNAP_UPGRADE_LIST" | tee -a "$LOGFILE"

  # Refresh Snap packages
  echo -e "$(date) - ${YELLOW}Refreshing Snap packages...${NC}" | tee -a "$LOGFILE"
  sudo "$SNAP_CMD" refresh | tee -a "$LOGFILE"
  echo -e "$(date) - ${GREEN}Snap packages updated successfully.${NC}" | tee -a "$LOGFILE"
fi

# Check and update Flatpak packages if available
if command -v "$FLATPAK_CMD" &> /dev/null; then
  echo -e "$(date) - ${YELLOW}Checking for Flatpak package updates...${NC}" | tee -a "$LOGFILE"
  FLATPAK_UPGRADE_LIST=$("$FLATPAK_CMD" remote-ls --updates)

  if [ -z "$FLATPAK_UPGRADE_LIST" ]; then
    echo -e "$(date) - ${BLUE}No Change: All Flatpak packages are up to date.${NC}" | tee -a "$LOGFILE"
  else
    echo -e "$(date) - ${GREEN}The following Flatpak packages will be upgraded:${NC}" | tee -a "$LOGFILE"
    echo "$(date) - $FLATPAK_UPGRADE_LIST" | tee -a "$LOGFILE"

    # Update Flatpak packages
    echo -e "$(date) - ${YELLOW}Updating Flatpak packages...${NC}" | tee -a "$LOGFILE"
    "$FLATPAK_CMD" update -y | tee -a "$LOGFILE"
    echo -e "$(date) - ${GREEN}Flatpak packages updated successfully.${NC}" | tee -a "$LOGFILE"
  fi
else
  echo -e "$(date) - ${YELLOW}Flatpak is not installed, skipping Flatpak updates.${NC}" | tee -a "$LOGFILE"
fi

##############################
# FRIENDLY CAPSULES-UNSUPPORTED CHECK
##############################
echo -e "$(date) - ${YELLOW}Checking for firmware (fwupd) updates...${NC}" | tee -a "$LOGFILE"

# 1. Capture the fwupd refresh output
FWUPD_REFRESH_OUTPUT=$(sudo "$FWUPD_CMD" refresh --force 2>&1 | tee -a "$LOGFILE")

# 2. Check how many firmware updates are available (via JSON)
FWUPD_UPDATES=$(sudo "$FWUPD_CMD" get-updates --json 2>&1 | tee -a "$LOGFILE" | jq '.Devices | length')

if [ "$FWUPD_UPDATES" -eq 0 ]; then
  echo -e "$(date) - ${BLUE}No Change: No firmware updates available.${NC}" | tee -a "$LOGFILE"
else
  echo -e "$(date) - ${GREEN}Firmware updates are available for some devices:${NC}" | tee -a "$LOGFILE"
  sudo "$FWUPD_CMD" get-updates | tee -a "$LOGFILE"

  echo -e "$(date) - ${YELLOW}Updating system firmware via fwupd...${NC}" | tee -a "$LOGFILE"
  
  # 3. Capture the fwupd update output
  FWUPD_UPDATE_OUTPUT=$(sudo "$FWUPD_CMD" update -y 2>&1 | tee -a "$LOGFILE")

  # Combine for scanning
  ALL_FWUPD_OUTPUT="$FWUPD_REFRESH_OUTPUT\n$FWUPD_UPDATE_OUTPUT"

  # Check success/failure
  # We'll rely on the exit code of the last command in the pipeline
  FWUPD_EXIT_CODE=${PIPESTATUS[0]}
  if [ "$FWUPD_EXIT_CODE" -eq 0 ]; then
    echo -e "$(date) - ${GREEN}Firmware updated successfully (or no further action needed).${NC}" | tee -a "$LOGFILE"
  else
    echo -e "$(date) - ${YELLOW}Firmware update partially failed or was not applicable.${NC}" | tee -a "$LOGFILE"
  fi

  # 4. Check specifically for "capsules-unsupported" in combined output
  if echo "$ALL_FWUPD_OUTPUT" | grep -qi "capsules-unsupported"; then
    echo -e "\n$(date) - ${YELLOW}NOTE: UEFI capsule updates are not supported or disabled on this system.${NC}" | tee -a "$LOGFILE"
    echo -e "$(date) - ${YELLOW}BIOS/UEFI firmware won't update automatically via fwupd,${NC}" | tee -a "$LOGFILE"
    echo -e "$(date) - ${YELLOW}but other device firmware (SSD, USB receivers, etc.) may still have been updated.${NC}\n" | tee -a "$LOGFILE"
  fi
fi

echo -e "$(date) - ${GREEN}System update completed successfully (with capsule updates ignored if unsupported).${NC}" | tee -a "$LOGFILE"
