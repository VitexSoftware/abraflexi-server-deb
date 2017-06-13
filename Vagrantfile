# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/stretch64"
  config.vm.hostname = "flexibee-server";
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
     push.app = "vitexsoftware/flexibee"
   end

   config.vm.provision "shell", inline: <<-SHELL
     apt-get update
     export DEBIAN_FRONTEND="noninteractive"
     echo cs_CZ.utf8 UTF-8 >> /etc/locale.gen
     locale-gen 
     update-locale
     export LC_ALL="cs_CZ.utf8"
     echo network winstrom/local-network string | debconf-set-selections

     apt-get -y install gdebi-core curl locales
     CURVER="`curl -s https://www.flexibee.eu/podpora/stazeni-flexibee/stazeni-ekonomickeho-systemu-flexibee-linux/ | grep h2 | awk '{gsub("<[^>]*>", "")}1'| awk '{print $2}'`"
     IFS='.' read -r -a array <<< "$CURVER"
     GETURL="http://download.flexibee.eu/download/${array[0]}.${array[1]}/$CURVER/flexibee_${CURVER}_all.deb"
     wget $GETURL
     gdebi --n --q flexibee_${CURVER}_all.deb
     echo FLEXIBEE_CFG=server >> /etc/default/flexibee
     dpkg-reconfigure flexibee
     service flexibee status
   SHELL
end
