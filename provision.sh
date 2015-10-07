#!/usr/bin/env bash

#  ___ _____ ___ _  ___  _____ 
# / __|_   _| __| |/ / |/ / __|
# \__ \ | | | _|| ' <| ' <| _| 
# |___/ |_| |___|_|\_\_|\_\___|
#
# MY VAGRANT PROVISION


# By storing the date now, we can calculate the duration of provisioning at the
# end of this script.
start_seconds="$(date +%s)"

echo "
 ___ _____ ___ _  ___  _____ 
/ __|_   _| __| |/ / |/ / __|
\__ \ | | | _|| ' <| ' <| _| 
|___/ |_| |___|_|\_\_|\_\___|

STARTING PROVISION SCRIPT...
"


# Network Detection
#
# Make an HTTP request to google.com to determine if outside access is available
# to us. If 3 attempts with a timeout of 5 seconds are not successful, then we'll
# skip a few things further in provisioning rather than create a bunch of errors.
if [[ "$(wget --tries=3 --timeout=5 --spider http://google.com 2>&1 | grep 'connected')" ]]; then
    echo "Network connection detected..."
    ping_result="Connected"
else
    echo "Network connection not detected. Unable to reach google.com..."
    ping_result="Not Connected"
fi

# Git Config and set Owner
#curl https://gist.github.com/fideloper/3751524/raw/.gitconfig > /home/vagrant/.gitconfig
#sudo chown vagrant:vagrant /home/vagrant/.gitconfig

# Install Vundle and set finally owner of .vim files
#git clone https://github.com/gmarik/vundle.git /home/vagrant/.vim/bundle/vundle
#sudo chown -R vagrant:vagrant /home/vagrant/.vim

# Grab my .vimrc and set owner
#curl https://gist.github.com/fideloper/a335872f476635b582ee/raw/.vimrc > /home/vagrant/.vimrc
#sudo chown vagrant:vagrant /home/vagrant/.vimrc

# PACKAGE INSTALLATION
#
# Build a bash array to pass all of the packages we want to install to a single
# apt-get command. This avoids doing all the leg work each time a package is
# set to install. It also allows us to easily comment out or add single
# packages. We set the array as empty to begin with so that we can append
# individual packages to it as required.
apt_package_install_list=()

# Start with a bash array containing all packages we want to install in the
# virtual machine. We'll then loop through each of these and check individual
# status before adding them to the apt_package_install_list array.
apt_package_check_list=(

    # PHP5
    #
    # Our base packages for php5. As long as php5-fpm and php5-cli are
    # installed, there is no need to install the general php5 package, which
    # can sometimes install apache as a requirement.
    php5-fpm
    php5-cli

    # Common and dev packages for php
    php5-common
    php5-dev

    # Extra PHP modules that we find useful
    php5-memcache
    php5-imagick
    php5-mcrypt
    php5-mysql
    php5-imap
    php5-curl
    php-pear
    php5-gd
    php5-sybase

    # nginx is installed as the default web server
    nginx

    # memcached is made available for object caching
    memcached

    # mysql is the default database
    mysql-server

    # other packages that come in handy
    imagemagick
    subversion
    git-core
    zip
    unzip
    ngrep
    curl
    make
    vim
    colordiff
    #postfix
    htop

    # ntp service to keep clock current
    ntp

    # Req'd for i18n tools
    gettext

    # Req'd for Webgrind
    graphviz

    # dos2unix
    # Allows conversion of DOS style line endings to something we'll have less
    # trouble with in Linux.
    dos2unix

    # nodejs for use by grunt
    g++
    nodejs
    npm

    #Mailcatcher requirement
    libsqlite3-dev
)

echo "Check for apt packages to install..."

# Loop through each of our packages that should be installed on the system. If
# not yet installed, it should be added to the array of packages to install.
for pkg in "${apt_package_check_list[@]}"; do
    package_version="$(dpkg -s $pkg 2>&1 | grep 'Version:' | cut -d " " -f 2)"
    if [[ -n "${package_version}" ]]; then
        space_count="$(expr 20 - "${#pkg}")" #11
        pack_space_count="$(expr 30 - "${#package_version}")"
        real_space="$(expr ${space_count} + ${pack_space_count} + ${#package_version})"
        printf " * $pkg %${real_space}.${#package_version}s ${package_version}\n"
    else
        echo " *" $pkg [not installed]
        apt_package_install_list+=($pkg)
    fi
done

# MySQL
#
# Use debconf-set-selections to specify the default password for the root MySQL
# account. This runs on every provision, even if MySQL has been installed. If
# MySQL is already installed, it will not affect anything.
echo mysql-server mysql-server/root_password password root | debconf-set-selections
echo mysql-server mysql-server/root_password_again password root | debconf-set-selections

if [[ $ping_result == "Connected" ]]; then
    # If there are any packages to be installed in the apt_package_list array,
    # then we'll run `apt-get update` and then `apt-get install` to proceed.
    if [[ ${#apt_package_install_list[@]} = 0 ]]; then
        echo -e "No apt packages to install.\n"
    else
        # update all of the package references before installing anything
        echo "Running apt-get update..."
        apt-get update --assume-yes

        # install required packages
        echo "Installing apt-get packages..."
        apt-get install --assume-yes ${apt_package_install_list[@]}

        # Clean up apt caches
        apt-get clean
    fi

    # "/usr/bin/env: node: No such file or directory" FIX
    # If you install nodejs from a package manager your bin may be called nodejs so you just need to symlink it
    ln -s /usr/bin/nodejs /usr/bin/node

    # npm
    #
    # Make sure we have the latest npm version and the update checker module
    npm install -g npm
    npm install -g npm-check-updates

    # xdebug
    #
    # XDebug 2.2.3 is provided with the Ubuntu install by default. The PECL
    # installation allows us to use a later version. Not specifying a version
    # will load the latest stable.
    pecl install xdebug

    # ack-grep
    #
    # Install ack-rep directory from the version hosted at beyondgrep.com as the
    # PPAs for Ubuntu Precise are not available yet.
    if [[ -f /usr/bin/ack ]]; then
        echo "ack-grep already installed"
    else
        echo "Installing ack-grep as ack"
        curl -s http://beyondgrep.com/ack-2.04-single-file > /usr/bin/ack && chmod +x /usr/bin/ack
    fi

    # COMPOSER
    #
    # Install Composer if it is not yet available.
    if [[ ! -n "$(composer --version --no-ansi | grep 'Composer version')" ]]; then
        echo "Installing Composer..."
        curl -sS https://getcomposer.org/installer | php
        chmod +x composer.phar
        mv composer.phar /usr/local/bin/composer
    fi

    if [[ -f /vagrant/provision/github.token ]]; then
        ghtoken=`cat /vagrant/provision/github.token`
        composer config --global github-oauth.github.com $ghtoken
        echo "Your personal GitHub token is set for Composer."
    fi

    # Update both Composer and any global packages. Updates to Composer are direct from
    # the master branch on its GitHub repository.
    if [[ -n "$(composer --version --no-ansi | grep 'Composer version')" ]]; then
        echo "Updating Composer..."
        COMPOSER_HOME=/usr/local/src/composer composer self-update
        COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update phpunit/phpunit:4.3.*
        COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update phpunit/php-invoker:1.1.*
        COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update mockery/mockery:0.9.*
        COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update d11wtq/boris:v1.0.8
        COMPOSER_HOME=/usr/local/src/composer composer -q global config bin-dir /usr/local/bin
        COMPOSER_HOME=/usr/local/src/composer composer global update
    fi

    # Grunt
    #
    # Install or Update Grunt based on current state.  Updates are direct
    # from NPM
    if [[ "$(grunt --version)" ]]; then
        echo "Updating Grunt CLI"
        npm update -g grunt-cli &>/dev/null
        npm update -g grunt-contrib-less &>/dev/null
        npm update -g grunt-contrib-jade &>/dev/null
        npm update -g grunt-contrib-jshint &>/dev/null
    else
        echo "Installing Grunt CLI"
        npm install -g grunt-cli &>/dev/null
        npm install -g grunt-contrib-less &>/dev/null
        npm install -g grunt-contrib-jade &>/dev/null
        npm install -g grunt-contrib-jshint &>/dev/null
    fi

    # Graphviz
    #
    # Set up a symlink between the Graphviz path defined in the default Webgrind
    # config and actual path.
    echo "Adding graphviz symlink for Webgrind..."
    ln -sf /usr/bin/dot /usr/local/bin/dot

else
    echo -e "\nNo network connection available, skipping package installation"
fi

echo -e "\nSetup configuration files..."

# Copy nginx configuration from local
cp /srv/config/nginx-config/nginx.conf /etc/nginx/nginx.conf
cp /srv/config/nginx-config/default.conf /etc/nginx/sites-available/default.conf

echo " * Copied /srv/config/nginx-config/nginx.conf           to /etc/nginx/nginx.conf"
echo " * Copied /srv/config/nginx-config/default.conf to /etc/nginx/sites-available/default.conf"

# Copy php-fpm configuration from local
cp /srv/config/php5-fpm-config/php5-fpm.conf /etc/php5/fpm/php5-fpm.conf
cp /srv/config/php5-fpm-config/www.conf /etc/php5/fpm/pool.d/www.conf
cp /srv/config/php5-fpm-config/php-custom.ini /etc/php5/fpm/conf.d/php-custom.ini
cp /srv/config/php5-fpm-config/opcache.ini /etc/php5/fpm/conf.d/opcache.ini
cp /srv/config/php5-fpm-config/xdebug.ini /etc/php5/mods-available/xdebug.ini

# Find the path to Xdebug and prepend it to xdebug.ini
XDEBUG_PATH=$( find /usr -name 'xdebug.so' | head -1 )
sed -i "1izend_extension=\"$XDEBUG_PATH\"" /etc/php5/mods-available/xdebug.ini

echo " * Copied /srv/config/php5-fpm-config/php5-fpm.conf     to /etc/php5/fpm/php5-fpm.conf"
echo " * Copied /srv/config/php5-fpm-config/www.conf          to /etc/php5/fpm/pool.d/www.conf"
echo " * Copied /srv/config/php5-fpm-config/php-custom.ini    to /etc/php5/fpm/conf.d/php-custom.ini"
echo " * Copied /srv/config/php5-fpm-config/opcache.ini       to /etc/php5/fpm/conf.d/opcache.ini"
echo " * Copied /srv/config/php5-fpm-config/xdebug.ini        to /etc/php5/mods-available/xdebug.ini"

# Copy memcached configuration from local
cp /srv/config/memcached-config/memcached.conf /etc/memcached.conf

echo " * Copied /srv/config/memcached-config/memcached.conf   to /etc/memcached.conf"

# Copy custom dotfiles and bin file for the vagrant user from local
cp /srv/config/bash_profile /home/vagrant/.bash_profile
cp /srv/config/bash_aliases /home/vagrant/.bash_aliases
cp /srv/config/bashrc /home/vagrant/.bashrc
cp /srv/config/vimrc /home/vagrant/.vimrc
rsync -rvzh --delete /srv/config/homebin/ /home/vagrant/bin/

echo " * Copied /srv/config/bash_profile                      to /home/vagrant/.bash_profile"
echo " * Copied /srv/config/bash_aliases                      to /home/vagrant/.bash_aliases"
echo " * Copied /srv/config/vimrc                             to /home/vagrant/.vimrc"
echo " * rsync'd /srv/config/homebin                          to /home/vagrant/bin"

# RESTART SERVICES
#
# Make sure the services we expect to be running are running.
echo -e "\nRestart services..."
service nginx restart
service memcached restart

# Disable PHP Xdebug module by default
php5dismod xdebug

# Enable PHP mcrypt module by default
php5enmod mcrypt

service php5-fpm restart

# Add the vagrant user to the www-data group so that it has better access
# to PHP and Nginx related files.
usermod -a -G www-data vagrant

# If MySQL is installed, go through the various imports and service tasks.
exists_mysql="$(service mysql status)"
if [[ "mysql: unrecognized service" != "${exists_mysql}" ]]; then
    echo -e "\nSetup MySQL configuration file links..."

    # Copy mysql configuration from local
    cp /srv/config/mysql-config/my.cnf /etc/mysql/my.cnf
    cp /srv/config/mysql-config/root-my.cnf /home/vagrant/.my.cnf

    echo " * Copied /srv/config/mysql-config/my.cnf               to /etc/mysql/my.cnf"
    echo " * Copied /srv/config/mysql-config/root-my.cnf          to /home/vagrant/.my.cnf"

    # MySQL gives us an error if we restart a non running service, which
    # happens after a `vagrant halt`. Check to see if it's running before
    # deciding whether to start or restart.
    if [[ "mysql stop/waiting" == "${exists_mysql}" ]]; then
        echo "service mysql start"
        service mysql start
    else
        echo "service mysql restart"
        service mysql restart
    fi

    # IMPORT SQL
    #
    # Create the databases (unique to system) that will be imported with
    # the mysqldump files located in database/backups/
    if [[ -f /srv/database/init-custom.sql ]]; then
        mysql -u root -proot < /srv/database/init-custom.sql
        echo -e "\nInitial custom MySQL scripting..."
    else
        echo -e "\nNo custom MySQL scripting found in database/init-custom.sql, skipping..."
    fi

    # Setup MySQL by importing an init file that creates necessary
    # users and databases that our vagrant setup relies on.
    mysql -u root -proot < /srv/database/init.sql
    echo "Initial MySQL prep..."

    # Process each mysqldump SQL file in database/backups to import
    # an initial data set for MySQL.
    /srv/database/import-sql.sh
else
    echo -e "\nMySQL is not installed. No databases imported."
fi

end_seconds="$(date +%s)"
echo "-----------------------------"
echo "Provisioning complete in "$(expr $end_seconds - $start_seconds)" seconds"
if [[ $ping_result == "Connected" ]]; then
    echo "External network connection established, packages up to date."
else
    echo "No external network available. Package installation and maintenance skipped."
fi