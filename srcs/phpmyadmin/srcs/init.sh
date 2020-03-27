#!/bin/sh

# Abort on error
set -e

if [ -f "/usr/share/phpmyadmin/config.inc.php" ]; then
    echo "Already configured..."
else
    echo "Downloading phpMyAdmin..."
    # Setup phpmyadmin
    wget -qO /tmp/phpmyadmin.zip https://files.phpmyadmin.net/phpMyAdmin/${phpmyadmin_version}/phpMyAdmin-${phpmyadmin_version}-all-languages.zip
    cd /tmp
    unzip phpmyadmin.zip
    rm -f phpmyadmin.zip
    mv phpMyAdmin-${phpmyadmin_version}-all-languages/* /usr/share/phpmyadmin/

    echo "Setting up phpMyAdmin..."
    cd /usr/share/phpmyadmin
    BLOWFISH=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '${BLOWFISH}'|"\
    -e "s|cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost'|cfg['Servers'][\$i]['host'] = '${MYSQL_HOST}'|"\
    config.sample.inc.php > config.inc.php
    chown -R ${WWW_USER}:${WWW_USER} /usr/share/phpmyadmin
    echo "Done!"
fi