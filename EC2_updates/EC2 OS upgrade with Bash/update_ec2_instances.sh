#!/bin/bash

# Default PEM key path
default_key_path="/home/ignar-valme-p42/work/pem files/data-team_key/data-team.pem"

# Define your instances with their respective details
instances=(
    "etl-process-odoo ec2-3-228-79-110.compute-1.amazonaws.com ec2-user"
    # "etl-process-swordfish ec2-34-230-144-23.compute-1.amazonaws.com ec2-user"
    #"etl-process-1CRM ec2-3-81-176-202.compute-1.amazonaws.com ec2-user /home/ignar-valme-p42/work/pem files/etl-process/etl-process-key.pem"
    # Add more instances as needed, uncomment and adjust the lines
)

# Function to check for running dnf or yum processes
check_package_manager_lock() {
    instance=$1
    host=$2
    user=$3
    key_path=${4:-$default_key_path}  # Use default key path if not provided

    echo "Checking for running package manager processes on $instance ($host)..."
    lock_check=$(ssh -i "$key_path" -o StrictHostKeyChecking=no $user@$host "ps aux | grep -E 'dnf|yum' | grep -v grep")
    if [ -n "$lock_check" ]; then
        echo "Package manager process is already running on $instance ($host). Details:"
        echo "$lock_check"
        return 1
    else
        echo "No package manager processes running on $instance ($host)."
        return 0
    fi
}

# Function to update a single instance
update_instance() {
    instance=$1
    host=$2
    user=$3
    key_path=${4:-$default_key_path}  # Use default key path if not provided

    echo "Updating $instance ($host)..."
    update_output=$(ssh -i "$key_path" -o StrictHostKeyChecking=no $user@$host "sudo dnf -y upgrade" 2>&1)
    update_exit_code=$?
    if [ $update_exit_code -eq 0 ]; then
        echo "Successfully updated $instance ($host)"
    else
        echo "Failed to update $instance ($host). Exit code: $update_exit_code. Details:"
        echo "$update_output"
    fi
}

# Iterate over each instance configuration
for instance_config in "${instances[@]}"
do
    IFS=' ' read -r name host user key_path <<< "$instance_config"
    # Check for running dnf or yum processes before updating
    if check_package_manager_lock "$name" "$host" "$user" "$key_path"; then
        update_instance "$name" "$host" "$user" "$key_path"
    else
        echo "Skipping update for $instance ($host) due to running package manager process."
    fi
done

echo "Update process completed for all instances."

