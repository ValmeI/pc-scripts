#!/bin/bash

LOGDIR="/home/ignar-valme-p42/linux-scripts/script_logs"
LOGFILE="$LOGDIR/$(date +%Y%m%d_%H%M%S)_update.log"
TIMESHIFT_CMD="timeshift"
APT_CMD="apt-get"
SNAP_CMD="snap"
FLATPAK_CMD="flatpak"
FWUPD_CMD="fwupdmgr"

# Ensure log directory exists
mkdir -p "$LOGDIR"

# Trap signals to ensure cleanup
trap 'echo "$(date) - Script interrupted." | tee -a "$LOGFILE"; exit 1' INT TERM

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root" | tee -a "$LOGFILE"
  exit 1
fi

# Check for essential commands
for cmd in ping df $APT_CMD $TIMESHIFT_CMD $SNAP_CMD $FLATPAK_CMD $FWUPD_CMD; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "$(date) - Command $cmd is not available. Please install it before running this script." | tee -a "$LOGFILE"
    exit 1
  fi
done

# Check for internet connectivity
if ! ping -c 1 google.com &> /dev/null; then
  echo "No internet connection. Please check your network settings." | tee -a "$LOGFILE"
  exit 1
fi

# Check for disk space (ensure at least 2GB free space)
FREE_SPACE=$(df / | tail -1 | awk '{print $4}')
if [ "$FREE_SPACE" -lt 2097152 ]; then
  echo "Not enough disk space. At least 2GB free space is required." | tee -a "$LOGFILE"
  exit 1
fi

# Check if timeshift command is available
if ! command -v "$TIMESHIFT_CMD" &> /dev/null; then
    echo "$(date) - Timeshift is not installed. Installing..." | tee -a "$LOGFILE"
    if ! sudo "$APT_CMD" install timeshift -y | tee -a "$LOGFILE"; then
      echo "Failed to install Timeshift" | tee -a "$LOGFILE"
      exit 1
    fi
fi

# Create a Timeshift backup
echo "$(date) - Creating a Timeshift backup..." | tee -a "$LOGFILE"
if ! sudo "$TIMESHIFT_CMD" --create --comments "Backup before system update" | tee -a "$LOGFILE"; then
  echo "Failed to create Timeshift backup" | tee -a "$LOGFILE"
  exit 1
fi

# Update and upgrade APT packages
echo "$(date) - Updating APT package list..." | tee -a "$LOGFILE"
if ! sudo "$APT_CMD" update | tee -a "$LOGFILE"; then
  echo "Failed to update APT package list" | tee -a "$LOGFILE"
  exit 1
fi

echo "$(date) - Upgrading APT packages..." | tee -a "$LOGFILE"
if ! sudo "$APT_CMD" e upgrad-y | tee -a "$LOGFILE"; then
  echo "Failed to upgrade APT packages" | tee -a "$LOGFILE"
  exit 1
fi

# Perform full upgrade (includes package removals and new dependencies)
echo "$(date) - Performing full upgrade..." | tee -a "$LOGFILE"
if ! sudo "$APT_CMD" full-upgrade -y | tee -a "$LOGFILE"; then
  echo "Failed to perform full upgrade" | tee -a "$LOGFILE"
  exit 1
fi

# Remove unnecessary packages
echo "$(date) - Removing unnecessary packages..." | tee -a "$LOGFILE"
if ! sudo "$APT_CMD" autoremove -y | tee -a "$LOGFILE"; then
  echo "Failed to remove unnecessary packages" | tee -a "$LOGFILE"
  exit 1
fi

# Clean up .deb files of packages that are no longer installed
echo "$(date) - Cleaning up .deb files of packages that are no longer installed..." | tee -a "$LOGFILE"
if ! sudo "$APT_CMD" autoclean -y | tee -a "$LOGFILE"; then
  echo "Failed to clean up .deb files" | tee -a "$LOGFILE"
  exit 1
fi

# Refresh Snap packages
echo "$(date) - Refreshing Snap packages..." | tee -a "$LOGFILE"
if ! sudo "$SNAP_CMD" refresh | tee -a "$LOGFILE"; then
  echo "Failed to refresh Snap packages" | tee -a "$LOGFILE"
  exit 1
fi

# Check if flatpak command is available
if ! command -v "$FLATPAK_CMD" &> /dev/null; then
    echo "$(date) - Flatpak is not installed. Installing..." | tee -a "$LOGFILE"
    if ! sudo "$APT_CMD" install flatpak -y | tee -a "$LOGFILE"; then
      echo "Failed to install Flatpak" | tee -a "$LOGFILE"
      exit 1
    fi
fi

# Update Flatpak packages
echo "$(date) - Updating Flatpak packages..." | tee -a "$LOGFILE"
if ! "$FLATPAK_CMD" update -y | tee -a "$LOGFILE"; then
  echo "Failed to update Flatpak packages" | tee -a "$LOGFILE"
  exit 1
fi

echo "$(date) - All updates are complete." | tee -a "$LOGFILE"

# Update system firmware
echo "$(date) - Updating system firmware..." | tee -a "$LOGFILE"
if ! sudo "$FWUPD_CMD" refresh | tee -a "$LOGFILE"; then
  echo "Failed to refresh firmware updates" | tee -a "$LOGFILE"
  exit 1
fi

if ! sudo "$FWUPD_CMD" get-updates | tee -a "$LOGFILE"; then
  echo "Failed to get firmware updates" | tee -a "$LOGFILE"
  exit 1
fi

if ! sudo "$FWUPD_CMD" update | tee -a "$LOGFILE"; then
  echo "Failed to update system firmware" | tee -a "$LOGFILE"
  exit 1
fi

echo "$(date) - System firmware updated successfully." | tee -a "$LOGFILE"
