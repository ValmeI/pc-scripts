#!/bin/bash

# Log directory and file setup
LOGDIR="$HOME/linux-scripts/script_logs"
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

# Check if nala is installed; if so, use it instead of apt-get
if command -v nala &> /dev/null; then
  APT_CMD="nala"
  echo "$(date) - Using nala for package updates." | tee -a "$LOGFILE"
else
  echo "$(date) - Nala not found, falling back to apt-get." | tee -a "$LOGFILE"
fi

# Ensure essential commands are available
for cmd in "$APT_CMD" "$TIMESHIFT_CMD" "$SNAP_CMD" "$FLATPAK_CMD" "$FWUPD_CMD"; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "$(date) - Command $cmd is not available. Installing..." | tee -a "$LOGFILE"
    sudo apt-get install "$cmd" -y || { echo "Failed to install $cmd"; exit 1; }
  fi
done

# Perform a Timeshift backup
echo "$(date) - Creating a Timeshift backup..." | tee -a "$LOGFILE"
sudo "$TIMESHIFT_CMD" --create --comments "Backup before system update" | tee -a "$LOGFILE"

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

# Update and upgrade APT (or Nala) packages
echo "$(date) - Updating package list with $APT_CMD..." | tee -a "$LOGFILE"
sudo "$APT_CMD" update | tee -a "$LOGFILE"

echo "$(date) - Upgrading packages with $APT_CMD..." | tee -a "$LOGFILE"
sudo "$APT_CMD" upgrade -y | tee -a "$LOGFILE"

# Perform full upgrade (includes package removals and new dependencies)
echo "$(date) - Performing full upgrade..." | tee -a "$LOGFILE"
sudo "$APT_CMD" full-upgrade -y | tee -a "$LOGFILE"

# Remove unnecessary packages
echo "$(date) - Removing unnecessary packages..." | tee -a "$LOGFILE"
sudo "$APT_CMD" autoremove -y | tee -a "$LOGFILE"

# Clean up .deb files of packages that are no longer installed
if [ "$APT_CMD" = "apt-get" ]; then
  echo "$(date) - Cleaning up .deb files of packages that are no longer installed..." | tee -a "$LOGFILE"
  sudo "$APT_CMD" autoclean -y | tee -a "$LOGFILE"
fi

# Refresh Snap packages
echo "$(date) - Refreshing Snap packages..." | tee -a "$LOGFILE"
sudo "$SNAP_CMD" refresh | tee -a "$LOGFILE"

# Check and update Flatpak packages if available
if command -v "$FLATPAK_CMD" &> /dev/null; then
  echo "$(date) - Updating Flatpak packages..." | tee -a "$LOGFILE"
  "$FLATPAK_CMD" update -y | tee -a "$LOGFILE"
else
  echo "$(date) - Flatpak is not installed, skipping Flatpak updates." | tee -a "$LOGFILE"
fi

# Update system firmware
echo "$(date) - Updating system firmware..." | tee -a "$LOGFILE"
sudo "$FWUPD_CMD" refresh | tee -a "$LOGFILE"
sudo "$FWUPD_CMD" get-updates | tee -a "$LOGFILE"
sudo "$FWUPD_CMD" update | tee -a "$LOGFILE"

echo "$(date) - System update completed successfully." | tee -a "$LOGFILE"
