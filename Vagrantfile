# Vagrantfile
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "debian/bullseye64"

  # 1. Servidor DNS 
  config.vm.define "dns" do |dns|
    dns.vm.hostname = "dns"
    dns.vm.network "private_network", ip: "192.168.58.10"
    dns.vm.provision "shell", path: "provision-dns.sh"
  end

  # 2. Servidor DHCP
  config.vm.define "dhcp" do |dhcp|
    dhcp.vm.hostname = "dhcp"
    dhcp.vm.network "private_network", ip: "192.168.58.20"
    dhcp.vm.provision "shell", path: "provision-dhcp.sh"
  end

  # 3. Cliente (Obtiene IP de DHCP)
  config.vm.define "client" do |client|
    client.vm.hostname = "c1" #
    client.vm.network "private_network", type: "dhcp"
    client.vm.provision "shell", path: "provision-client.sh"
  end
end