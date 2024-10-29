#!/bin/bash

# Define variables for paths
HOSTS_FILE="/home/ignar-valme-p42/linux-scripts/EC2_updates/Ansible/hosts.ini"
PLAYBOOK_FILE="/home/ignar-valme-p42/linux-scripts/EC2_updates/Ansible/update.yml"

# Check if the hosts file exists
if [ ! -f "$HOSTS_FILE" ]; then
    echo "Error: Hosts file not found at $HOSTS_FILE"
    exit 1
fi

# Check if the playbook file exists
if [ ! -f "$PLAYBOOK_FILE" ]; then
    echo "Error: Playbook file not found at $PLAYBOOK_FILE"
    exit 1
fi

# Run the ansible-playbook command with verbose output
ansible-playbook -i "$HOSTS_FILE" "$PLAYBOOK_FILE" -vvv

# Check the exit status of the ansible-playbook command
if [ $? -ne 0 ]; then
    echo "Error: ansible-playbook command failed."
    exit 1
else
    echo "ansible-playbook command executed successfully."
fi

