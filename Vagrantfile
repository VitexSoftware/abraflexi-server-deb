# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/buster64"
  config.vm.hostname = "abraflexi-server";
  config.vm.network "forwarded_port", guest: 5434, host: 5434

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  config.push.define "atlas" do |push|
     push.app = "vitexsoftware/abraflexi-server"
  end

   config.vm.provision "shell", inline: <<-SHELL
     apt-get update
     export DEBIAN_FRONTEND="noninteractive"
     echo cs_CZ.utf8 UTF-8 >> /etc/locale.gen
     locale-gen 
     update-locale
     export LC_ALL="cs_CZ.UTF-8"

     apt-get -y install gdebi-core curl locales mc htop screen net-tools html2text
     gdebi --n --q `ls /vagrant/abraflexi-server_*_all.deb`
     service abraflexi status

      curl -k -v https://127.0.0.1:5434/login-logout/first-user-form | html2text

   SHELL
end
