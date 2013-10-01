# -*- mode: ruby -*-
# vi: set ft=ruby :

raise "\n\nPlease set $GPFDIST_HOME to continue\n \n" if ENV["GPFDIST_HOME"].nil?

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "CentOS-6.4-GP4.2.6.1-2013081501"
  config.vm.box_url = "http://vboxes.ett.local/CentOS-6.4-GP4.2.6.1-2013081501.box"
  config.vm.network :private_network, ip: "192.168.56.42"

  config.vm.provider :virtualbox do |virtual_machine|
    virtual_machine.name = "smart-insight-devmachine"
  end

  config.vm.synced_folder ".", "/vagrant", :disabled => true
  config.vm.synced_folder ENV["GPFDIST_HOME"], "/home/gpadmin/smart-insight-data", owner: "gpadmin", group: "gpadmin"

  config.vm.provision :shell, :inline => "chown -R gpadmin.gpadmin /home/gpadmin"
end