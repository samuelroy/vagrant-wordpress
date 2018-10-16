# Wordpress 4.9.8 with Gutenberg (Vagrant)

Vagrant setup for running Wordpress 4.9.8 and WP-CLI on Debian 9.5 / Mariadb 10.0 / NGINX

## Instructions

Automatic download of wordpress 4.9.8 in folder `vagrant/wordpress`:

1. Open your terminal and run: `./setup.sh`
2. Launch the virtual machine with: `vagrant up`
3. Open your browser on http://localhost:8080
4. Connect as admin on http://localhost:8080/wp-admin, login: admin, password: admin

## Database

- user: root
- password: root
- database name: wordpress
- host: 127.0.0.1

Connect through SSH on port `2222` with host `127.0.0.1` and user `vagrant`. You can locate the required private key with the Vagrant command `vagrant ssh-config`.

