#!/bin/bash

# List of EC2 instance IP addresses or hostnames
instances=(
    "ec2-3-228-79-110.compute-1.amazonaws.com"    # Odoo instance
    "ec2-34-230-144-23.compute-1.amazonaws.com"   # Swordfish instance
    #"ec2-3-81-176-202.compute-1.amazonaws.com"    # 1CRM instance
    "ec2-18-211-171-195.compute-1.amazonaws.com"  # Lendfusion instance
    "ec2-52-22-107-221.compute-1.amazonaws.com"   # Odoo MX instance
    "ec2-54-160-41-210.compute-1.amazonaws.com"   # Swordfish logs instance
    #"ec2-34-230-79-220.compute-1.amazonaws.com"   # Inspection instance
    "ec2-34-228-149-231.compute-1.amazonaws.com"  # Odoo intermediary instance
)

# Path to the aliases file
alias_file="aliases.sh"

# Base directory for the AWS PEM key
PEM_KEY_PATH="/home/ignar-valme-p42/work/pem files/data-team_key/data-team.pem"

# Set the correct permissions for the PEM file
chmod 400 "$PEM_KEY_PATH"

# Loop through each instance and update the .bashrc file
for instance in "${instances[@]}"; do
    echo "Updating .bashrc on $instance"
    scp -i "$PEM_KEY_PATH" "$alias_file" ec2-user@$instance:/tmp/aliases.sh
    ssh -i "$PEM_KEY_PATH" ec2-user@$instance << 'EOF'
        # Append aliases to .bashrc
        cat /tmp/aliases.sh >> ~/.bashrc
        rm /tmp/aliases.sh
        source ~/.bashrc
        
        # Add sourcing of .bashrc to .bash_profile if not already present
        if ! grep -q 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' ~/.bash_profile; then
            echo -e '\n# Source .bashrc if it exists\nif [ -f ~/.bashrc ]; then\n    . ~/.bashrc\nfi' >> ~/.bash_profile
        fi
EOF
done

echo "All instances updated."

