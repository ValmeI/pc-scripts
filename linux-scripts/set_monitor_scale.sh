#!/bin/bash

# Log file location
LOGFILE=/home/ignar-valme-p42/monitor_scale.log

# Start logging
echo "Running set_monitor_scale.sh at $(date)" > $LOGFILE

# Enable fractional scaling
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']" >> $LOGFILE 2>&1

# Set text scaling factor
gsettings set org.gnome.desktop.interface text-scaling-factor 1.12 >> $LOGFILE 2>&1

# Adjust dock icon size
DOCK_ICON_SIZE=55  # Adjust this value as needed
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size $DOCK_ICON_SIZE >> $LOGFILE 2>&1

# Adjust cursor size
gsettings set org.gnome.desktop.interface cursor-size 34 >> $LOGFILE 2>&1

# Apply GTK scaling (add to profile for persistence)
#echo 'export GDK_SCALE=1' >> ~/.profile
#echo 'export GDK_DPI_SCALE=1.10' >> ~/.profile

echo "Scaling and dock adjustments applied successfully" >> $LOGFILE