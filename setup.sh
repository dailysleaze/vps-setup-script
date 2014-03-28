#!/bin/bash


# ------------ config -----------------
# set up email for logwatch
email=""

# public key for putting into .ssh/authorized_keys
pubkey=""

# ssh port
sshPort="657"

# setup
doSetup=true
doWebServer=true
doVnc=false


# mysql root password
# get ready to input it, it will pop up

# date
#now=`date +%F_%H%M%S`
# ------------ config -----------------



if $doSetup ; then
    # fix resolv.conf if you need to
    #echo -e "nameserver 8.8.8.8\nnameserver 4.2.2.2" > /etc/resolv.conf 

    # update and 
    sudo apt-get update 
    sudo apt-get -y upgrade 

    # nano + other apps for add-apt-repository cmd
    # http://stackoverflow.com/a/16032073
    sudo apt-get -y install nano ufw
    #WM python-software-properties software-properties-common

    # update time
    rm -f /etc/localtime
    ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
    sudo apt-get -y install ntp
    service ntp restart

    # bashrc
    #mv ~/.bashrc ~/.bashrc.bak
    #wget https://raw.github.com/amnah/vps-setup-script/master/files/.bashrc
    #mv .bashrc ~/.bashrc
    #chmod 644 ~/.bashrc


    #WM new user
    adduser dailysleaze

    # prevent root login with password (ssh keys only)
    mkdir ~/.ssh
    touch ~/.ssh/authorized_keys
    echo "$pubkey" > ~/.ssh/authorized_keys
    chmod 700 ~/.ssh 
    chmod 600 ~/.ssh/authorized_keys 
    chown -R root.root .ssh
    echo -e "\n\nPermitRootLogin no\n#PasswordAuthentication no\nUseDNS no\nAllowUsers dailysleaze" >> /etc/ssh/sshd_config
    sed -i "s/Port 22/Port $sshPort/g" /etc/ssh/sshd_config

    #Add user as admin
    visudo

    #Restart in the event of memory peak
    echo -e "\n\nvm.panic_on_oom=1\nkernel.panic=10" >> /etc/sysctl.conf

    #Firewall
    sudo apt-get install nmap
    nmap -v -sT localhost
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw logging on
    sudo ufw allow ssh/tcp
    sudo ufw allow http/tcp
    sudo ufw allow 443
    sudo ufw allow $sshPort
    sudo ufw enable
    sudo ufw status

    # fail2ban
    sudo apt-get -y install fail2ban    
    sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    echo -e "destemail = willmather43@hotmail.com\naction = %(action_mwl)s\n\n[ssh]\n\nenabled  = true\nport     = $sshPort\nfilter   = sshd\nlogpath  = /var/log/auth.log\nmaxretry = 6\n\n[ssh-ddos]\n\nenabled  = true\nport     = $sshPort\nfilter   = sshd-ddos\nlogpath  = /var/log/auth.log\nmaxretry = 6" >> /etc/fail2ban/jail.local
    
    # restart ssh and fail2ban services
    service ssh restart
    service fail2ban restart

    echo -e "order bind,hosts\nnospoof on" >> /etc/host.conf

    # empty out mail file
    cat /dev/null > /var/mail/root

fi

if $doWebServer ; then
    # git php nginx mysql
    # http://www.howtoforge.com/installing-nginx-with-php5-and-php-fpm-and-mysql-support-lemp-on-ubuntu-12.04-lts
    #sudo add-apt-repository -y ppa:git-core/ppa
    sudo apt-get update
    sudo apt-get -y purge apache2* libapache2*    
    sudo apt-get -y install apache2 curl git php5 php5-cli php5-gd php5-mcrypt php5-mysql mysql-server mysql-client
    # php5-fpm  php5-memcache php-apc php5-curl
    #sudo apt-get -y install php5-suhosin php5-intl php-pear php5-imap php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl
    #nano /etc/php5/cli/conf.d/ming.ini # change "#" to ";"

    #Apache disable modules
    sudo a2dismod autoindex

    # fix up some configs
    #sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini

    #Apache configuration
    sed -i "s/Timeout 300/Timeout 30/g" /etc/apache2/apache2.conf
    #TBC - Change to deny from all
    #sed -i "s/Alloow /Timeout 30/g" /etc/apache2/apache2.conf


    #TBC MYSQL
    #sudo apt-get install mysql-server mysql-client


    #TBC phpMyAdmin
    #sudo apt-get install phpmyadmin

    # download and install/move phpMyAdmin
    # note: file gets named "download"
    #wget http://sourceforge.net/projects/phpmyadmin/files/latest/download
    #unzip -q download 
    #rm -f download
    #mv phpMyAdmin* /data
    #ln -s /data/phpMyAdmin* /data/phpMyAdmin
    #wget https://raw.github.com/amnah/vps-setup-script/master/files/config.inc.php -O /data/phpMyAdmin/config.inc.php


    #TBC Git
    #git config --global user.name "your github username"
    #git config --global user.email "you@youremail.com"

    #TBC COmposer
    #curl -sS https://getcomposer.org/installer | php
    #sudo mv composer.phar /usr/local/bin/composer

    # set up data dir
    #mkdir -p /data/sites /data/logs
    #ln -s /etc/nginx/nginx.conf /data/nginx.conf
    #ln -s /etc/nginx/sites-available/ /data
    #ln -s /etc/nginx/sites-enabled/ /data
    #ln -s /etc/nginx/sites-available/_baseApps /etc/nginx/sites-enabled/_baseApps
    #wget https://raw.github.com/amnah/vps-setup-script/master/files/example.site -O /data/example.site

    

    # setup default + phpMyAdmin logs in nginx
    #mkdir /data/logs/_
    #touch /data/logs/_/access.log
    #touch /data/logs/_/error.log
    #mkdir /data/logs/phpMyAdmin
    #touch /data/logs/phpMyAdmin/access.log
    #touch /data/logs/phpMyAdmin/error.log

    # add logrotate to site logs and change rotation settings
    #sed -i "s/*.log/*.log \/data\/logs\/*\/*.log/g" /etc/logrotate.d/nginx
    #sed -i "s/daily/size=50M/g" /etc/logrotate.d/nginx
    #sed -i "s/daily/size=50M/g" /etc/logrotate.d/mysql-server
    #sed -i "s/rotate 7/rotate 52/g" /etc/logrotate.d/mysql-server

    # add fail2ban configurations
    # http://snippets.aktagon.com/snippets/554-how-to-secure-an-nginx-server-with-fail2ban
    # wget https://raw.github.com/amnah/vps-setup-script/master/files/filter.d/proxy.conf -O /etc/fail2ban/filter.d/proxy.conf
    # wget https://raw.github.com/amnah/vps-setup-script/master/files/filter.d/nginx-auth.conf -O /etc/fail2ban/filter.d/nginx-auth.conf
    # wget https://raw.github.com/amnah/vps-setup-script/master/files/filter.d/nginx-login.conf -O /etc/fail2ban/filter.d/nginx-login.conf
    # wget https://raw.github.com/amnah/vps-setup-script/master/files/filter.d/nginx-noscript.conf -O /etc/fail2ban/filter.d/nginx-noscript.conf
    # wget https://raw.github.com/amnah/vps-setup-script/master/files/filter.d/nginx-dos.conf -O /etc/fail2ban/filter.d/nginx-dos.conf
    # wget https://raw.github.com/amnah/vps-setup-script/master/files/jail.local.tmp -O /etc/fail2ban/jail.local.tmp

    # combine the tmp jail.local.tmp into the preconfigured jail.conf
    #cat /etc/fail2ban/jail.conf /etc/fail2ban/jail.local.tmp > /etc/fail2ban/jail.local
    #rm /etc/fail2ban/jail.local.tmp

    # restart nginx services
    service php5-fpm restart
    service apache2 restart

    # change owner and permissions
    #chown -R www-data.www-data /data/sites
    #find /data/sites -type d -print0 | xargs -0 chmod 0755    

    # clean up and download site.sh and backup.sh
    #wget https://raw.github.com/amnah/vps-setup-script/master/site.sh
    #wget https://raw.github.com/amnah/vps-setup-script/master/backup.sh
    #chmod 700 site.sh backup.sh

    # display message about site.sh
    echo -e "------------------------------------------"
    echo -e "Now go! Modify and run:\n"
    echo -e "   ./site.sh"

fi

if $doVnc ; then
    # install tightvnc and xfce
    sudo apt-get -y install tightvncserver xfce4 xfce4-goodies

    # update scripts
    mkdir ~/.vnc
    wget https://raw.github.com/amnah/vps-setup-script/master/files/xstartup  -O ~/.vnc/xstartup
    sed -i "s/#alias vnc/alias vnc/g" ~/.bashrc
    
    # display message about vnc
    echo -e "------------------------------------------"
    echo -e "Set up a vnc password:\n"
    echo -e "   echo 'password' | vncpasswd -f > ~/.vnc/passwd"
fi

# chmod script so it can't run again
chmod 400 setup.sh

# display finished message
echo -e "------------------------------------------"
echo -e "setup.sh finished"
echo -e "------------------------------------------"