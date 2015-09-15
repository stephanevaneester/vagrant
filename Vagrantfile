#  ___ _____ ___ _  ___  _____ 
# / __|_   _| __| |/ / |/ / __|
# \__ \ | | | _|| ' <| ' <| _| 
# |___/ |_| |___|_|\_\_|\_\___|
#
# MY VAGRANT CONFIGURATION

Vagrant.configure(2) do |config|

  # Default Ubuntu Box
  #
  # This box is provided by Ubuntu vagrantcloud.com and is a nicely sized (332MB)
  # box containing the Ubuntu 14.04 Trusty 64 bit release. Once this box is downloaded
  # to your host computer, it is cached for future use under the specified box name.
  config.vm.box = "ubuntu/trusty64"

  # Configuration options
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 2
    # Set the box name in VirtualBox to match the working directory.
    vvv_pwd = Dir.pwd
    vb.name = File.basename(vvv_pwd)
  end

  config.vm.network "forwarded_port", guest: 80, host: 58080
  config.vm.network "forwarded_port", guest: 3306, host: 53306

  # /srv/database/
  #
  # If a database directory exists in the same directory as your Vagrantfile,
  # a mapped directory inside the VM will be created that contains these files.
  # This directory is used to maintain default database scripts as well as backed
  # up mysql dumps (SQL files) that are to be imported automatically on vagrant up
  config.vm.synced_folder "database/", "/srv/database"

  # /srv/config/
  #
  # If a server-conf directory exists in the same directory as your Vagrantfile,
  # a mapped directory inside the VM will be created that contains these files.
  # This directory is currently used to maintain various config files for php and
  # nginx as well as any pre-existing database files.
  config.vm.synced_folder "config/", "/srv/config"

  # /srv/log/
  #
  # If a log directory exists in the same directory as your Vagrantfile, a mapped
  # directory inside the VM will be created for some generated log files.
  config.vm.synced_folder "log/", "/srv/log", :owner => "www-data"

  # /srv/www/
  #
  # If a www directory exists in the same directory as your Vagrantfile, a mapped directory
  # inside the VM will be created that acts as the default location for nginx sites. Put all
  # of your project files here that you want to access through the web server
  config.vm.synced_folder "www/", "/srv/www/", :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]
  
  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  # Provisioning
  #
  # Process provisioning script.  
  config.vm.provision "shell", path: "provision.sh"
end