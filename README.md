# Vagrant Project: Dynamic DNS (DDNS)

This project launches 3 machines (dns, dhcp, client) to test a Dynamic DNS setup with BIND9 and ISC-DHCP.

All configuration is **inside** the provisioning scripts. No config/ folder is needed.

-----

## IMPORTANT: Manual Setup
Because this is a "simulation" we cant give the secret DNS Password or key.

Before running vagrant up, you must **edit 2 files**:

    1.provision-dns.sh
    2.provision-dhcp.sh

In both files, find the line:
**DNS_KEY_SECRET="secret key**

- And replace "secret key" with a real secret key. You can generate one with this command:
 **sudo tsig-keygen -a hmac-sha256 ddns-key > /etc/bind/ddns.key**