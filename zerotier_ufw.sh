#!/bin/bash

# Function to get a network adapter starting with "zt"
get_zt_adapter() {
    ip link show | grep -oP 'zt\w+' | head -n 1
}

# Getting a network adapter
zt_adapter=$(get_zt_adapter)

if [ -z "$zt_adapter" ]; then
    echo "The network adapter starting with 'zt' could not be found."
    exit 1
fi

# Checking for files
if [ ! -f "allowed_ips.txt" ]; then
    echo "The file allowed_ips.txt not found."
    exit 1
fi

if [ ! -f "allowed_ports.txt" ]; then
    echo "The file allowed_ports.txt not found."
    exit 1
fi

# Reading IP addresses and ports from files, ignoring comments
allowed_ips=$(grep -v '^#' allowed_ips.txt)
allowed_ports=$(grep -v '^#' allowed_ports.txt)

# Clearing the previous rules for the specified ports
for port in $allowed_ports; do
    sudo ufw delete allow in on $zt_adapter to any port $port proto tcp
done

# Creating new rules
for ip in $allowed_ips; do
    for port in $allowed_ports; do
        sudo ufw allow in on $zt_adapter from $ip to any port $port proto tcp
    done
done

echo "The UFW rules have been successfully updated."
