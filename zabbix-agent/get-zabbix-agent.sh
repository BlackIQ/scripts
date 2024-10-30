#!/bin/bash

# Zabbix Agent 2 Installation Script for Ubuntu
#
# This script is a convenient way to configure the Zabbix package repositories
# and install Zabbix Agent 2 on Ubuntu servers. It is intended for users who
# want a quick and automated setup. This script is suitable for development or
# testing environments but may not be suitable for production use without
# verification. Please review the script for familiarity and customize if
# necessary.
#
# The script:
#
# - Requires `root` or `sudo` privileges to run.
# - Configures the Zabbix package repository for Ubuntu 20.04 LTS (Focal).
# - Installs the `libssl1.1` dependency for compatibility.
# - Installs the latest stable release of Zabbix Agent 2 for monitoring.
#
# Usage
# ==============================================================================
#
# To install Zabbix Agent 2 using this script:
#
# 1. Download and review the script
#
#    $ curl -fsSL https://cdn.amirhossein.info/scripts/zabbix/get-zabbix-agent.sh -o get-zabbix-agent.sh
#    $ cat get-zabbix-agent.sh
#
# 2. Run the script with `sudo` or as root
#
#    $ sudo sh get-zabbix-agent.sh
#
# Alternatively, run the script directly using `curl`:
#
#    $ curl -fsSL https://cdn.amirhossein.info/scripts/zabbix/get-zabbix-agent.sh | sudo sh

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Download Zabbix repository package
echo "Downloading Zabbix repository package..."
wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb

# Download libssl1.1 package for compatibility with zabbix-agent2
echo "Downloading libssl1.1 package..."
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# Install Zabbix repository package
echo "Installing Zabbix repository package..."
dpkg -i zabbix-release_5.0-1+focal_all.deb

# Install libssl1.1 dependency
echo "Installing libssl1.1 dependency..."
dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# Update package lists
echo "Updating package lists..."
apt update -y

# Install zabbix-agent2
echo "Installing Zabbix Agent 2..."
apt install zabbix-agent2 -y

# Confirm successful installation
if dpkg -l | grep -q zabbix-agent2; then
    echo "Zabbix Agent 2 has been installed successfully."
else
    echo "Installation failed."
fi
