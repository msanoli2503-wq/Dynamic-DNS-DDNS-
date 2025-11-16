#!/bin/bash
# provision-dns.sh

# --- 1. Key Variables ---
#
# CLARIFICATION: You must edit this key!
# Replace "secret key" with a real generated key 
# It MUST BE IDENTICAL to the key in provision-dhcp.sh.
#
DDNS_KEY_NAME="ddns-key"
DDNS_KEY_ALGORITHM="hmac-sha256"
DDNS_KEY_SECRET="secret key"


apt-get update
apt-get install -y bind9 bind9utils




cat > /etc/default/named << EOF
OPTIONS="-u bind -4"
EOF


cat > /etc/bind/named.conf.options << EOF
// DDNS Key Definition
key "$DDNS_KEY_NAME" {
    algorithm $DDNS_KEY_ALGORITHM;
    secret "$DDNS_KEY_SECRET";
};

acl "trusted" {
    192.168.58.0/24;
    localhost;
    localnets;
};

options {
    directory "/var/cache/bind";
    listen-on port 53 { 127.0.0.1; 192.168.58.10; };
    recursion yes;
    allow-recursion { "trusted"; };
    listen-on-v6 { none; };
    dnssec-validation auto;
    allow-transfer { none; };
};
EOF


cat > /etc/bind/named.conf.local << EOF
// File for /etc/bind/named.conf.local
zone "manu.test" {
    type master;
    file "/var/lib/bind/db.manu.test";
    allow-update { key "ddns-key"; };
};

zone "58.168.192.in-addr.arpa" {
    type master;
    file "/var/lib/bind/db.192";
    allow-update { key "ddns-key"; };
};
EOF

# File: /var/lib/bind/db.manu.test 
cat > /var/lib/bind/db.manu.test << EOF
\$TTL    604800
@   IN  SOA     dns.manu.test. root.manu.test. (
              1         ; Serial
         604800         ; Refresh
          86400         ; Retry
        2419200         ; Expire
         604800 )       ; Negative Cache TTL
;
@   IN  NS      dns.manu.test.
dns IN  A       192.168.58.10
dhcp IN A       192.168.58.20
EOF

# File: /var/lib/bind/db.192 (Reverse zone)
cat > /var/lib/bind/db.192 << EOF
\$TTL    604800
@   IN  SOA     dns.manu.test. root.manu.test. (
              1         ; Serial
         604800         ; Refresh
          86400         ; Retry
        2419200         ; Expire
         604800 )       ; Negative Cache TTL
;
@   IN  NS      dns.manu.test.
10  IN  PTR     dns.manu.test.
20  IN  PTR     dhcp.manu.test.
EOF

chown bind:bind /var/lib/bind/db.manu.test
chown bind:bind /var/lib/bind/db.192
chmod 664 /var/lib/bind/db.manu.test /var/lib/bind/db.192
systemctl restart bind9