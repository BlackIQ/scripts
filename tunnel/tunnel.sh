#!/bin/bash

# Check that user is admin
if [ $(whoami) != "root" ]; then
  echo "This script must be run as root"
  exit 1
fi

# Check that parameters are ok
if [ $# -ne 2 ]; then
  echo "Usage: $0 <in_ip> <out_ip>"
  exit 1
fi

# Define variables
in_ip=$1
out_ip=$2

# Doing iptables
sysctl net.ipv4.ip_forward=1
iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to-destination $in_ip
iptables -t nat -A PREROUTING -j DNAT --to-destination $out_ip
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables-save