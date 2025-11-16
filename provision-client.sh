#!/bin/bash
# provision-client.sh

apt-get update
apt-get install -y dnsutils

# Force DHCP renewal to register with DDNS
dhclient -r eth1
dhclient eth1