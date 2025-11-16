#!/bin/bash
# provision-dhcp.sh



DDNS_KEY_NAME="ddns-key"
DDNS_KEY_ALGORITHM="hmac-sha256"
DDNS_KEY_SECRET="secret key" #here is where you change the "key"

#  2. Install packages 
apt-get update
apt-get install -y isc-dhcp-server

#  3.  Now we create ALL DHCP configuration files 

# File: /etc/dhcp/ddns.key ( again with the key)
cat > /etc/dhcp/ddns.key << EOF
key "$DDNS_KEY_NAME" {
    algorithm $DDNS_KEY_ALGORITHM;
    secret "$DDNS_KEY_SECRET";
};
EOF

# File: /etc/dhcp/dhcpd.conf (main configuration)
cat > /etc/dhcp/dhcpd.conf << EOF
include "/etc/dhcp/ddns.key";

option domain-name "manu.test";
option domain-name-servers 192.168.58.10;

default-lease-time 86400;
max-lease-time 691200;
authoritative;

ddns-update-style interim;
ddns-domainname "manu.test.";
ddns-rev-domainname "58.168.192.in-addr.arpa.";

subnet 192.168.58.0 netmask 255.255.255.0 {
  range 192.168.58.100 192.168.58.200;
  option routers 192.168.58.1;

  zone manu.test. {
    primary 192.168.58.10;
    key "ddns-key";
  }
  zone 58.168.192.in-addr.arpa. {
    primary 192.168.58.10;
    key "ddns-key";
  }
}
EOF

# File: /etc/default/isc-dhcp-server (listening interface)
echo 'INTERFACESv4="eth1"' > /etc/default/isc-dhcp-server

# --- 4. Restart service ---
systemctl restart isc-dhcp-server