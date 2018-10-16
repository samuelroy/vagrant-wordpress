Vagrant.configure("2") do |config|
  config.vm.box = "debian/stretch64"
  config.vm.box_version = "9.5.0"

  config.vm.define :wordpress do |wordpress_config|
        wordpress_config.vm.hostname = 'wordpress'
        wordpress_config.vm.provision :shell, path: "bootstrap.sh"
  end

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3306, host: 3306

  config.vm.synced_folder "vagrant/confs", "/home/vagrant/confs"
  config.vm.synced_folder "vagrant/dumps", "/home/vagrant/dumps"
  config.vm.synced_folder "vagrant/wordpress", "/var/www/wordpress", owner: "www-data", group: "www-data"
end
