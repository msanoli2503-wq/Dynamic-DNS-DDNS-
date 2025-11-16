# THE PROCESS WE FOLLOWED
---

## 1.THE VAGRANTFILE
- We configure the [vagrant](https://github.com/msanoli2503-wq/Dynamic-DNS-DDNS-/blob/main/Vagrantfile) for three machines.
    
    1. DNS SERVER
    2. THE DHCP SERVER
    3. AND THE CLIENT
    
    ---

### 2.[PROVISION-DNS](https://github.com/msanoli2503-wq/Dynamic-DNS-DDNS-/blob/main/provision-dns.sh)

This script's job is to build the entire DNS server from scratch.

1. **Installs BIND9:** It first installs the **bind9** software, which is the program that **actualy** runs the DNS service.
2. **Writes the Secret Key:** It creates the **named.conf.options** file and writes the **key "ddns-key"** block. This is like creating a secret password (our secret key) and giving it a name. This tells the server, "Only trust **ppl** who know this password.

3. **Defines the Zone:** It creates **named.conf.local**to tell BIND,that it in controll of the domain .

4. **Sets the Update Rule:** This is the most **importent** part of that file. We add **allow-update { key "ddns-key"; }**. This is the *rule* that says, "You are allowed to make changes to this domain, but *only* if the request comes with the 'ddns-key' password you know."

* **THE CRITICAL STEP (Permissions):** 

    1. We run **chown bind:bind** and **chmod 664** on the zone files (like **db.manu.test**).

    2. **Why?** The BIND program should have root permission for security reasons. It runs as a special, less powerful user named **bind**. When our script first creates the config files, they are owned by **root**. If we don't change this, the **bind** user **wont** have **permision** to *edit* its own files, and the dynamic update (when the client joins) will fail. This step gives the **bind** user ownership and writing permission.

---

## 3. [PROVISION-DHCP](https://github.com/msanoli2503-wq/Dynamic-DNS-DDNS-/blob/main/provision-dhcp.sh)


1. **Writes its Copy of the Key:** It creates the **/etc/dhcp/ddns.key** file. This file *only* contains the **identcal** secret key. This is how the DHCP server "learns" the password.

2. **Writes the Main Config:** It creates the **dhcpd.conf** file. The key parts are:
    * **include "/etc/dhcp/ddns.key";**: This tells the DHCP server, to learn the se
    * **option domain-name "manu.test";**: Its tell this the domain anem.
    * **zone manu.test. { ... }**: This is the *instruction* that turns on DDNS. It tells the DHCP server: "When you give an IP to a new client, your job isn't finished. You must **immediatly** contact the DNS server (at **primary 192.168.58.10**) and use the **ddns-key** to tell it the new client's name and IP."

---

## 4.[PROVISION-CLIENT](https://github.com/msanoli2503-wq/Dynamic-DNS-DDNS-/blob/main/provision-client.sh)

This script is the simplest. **Its** only job is to start the whole process.

* **Installs Tools:** It installs **dnsutils**, which is just a helper program that gives us the **dig` command for testing **later**.
* **Triggers the Process:** It runs **dhclient -r** and **dhclient**. This forces the client to broadcast a message to the **entire** 