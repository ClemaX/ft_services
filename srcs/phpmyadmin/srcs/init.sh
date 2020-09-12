#!/bin/sh

# Abort on error
set -e

install_phpmyadmin()
{
	echo "Installing phpMyAdmin..."
    cd /tmp
    unzip -q /phpmyadmin.zip
    mv "phpMyAdmin-${phpmyadmin_version}-all-languages/" /usr/share/phpmyadmin/
}

setup_phpmyadmin()
{
	echo "Setting up phpMyAdmin..."
    cd /usr/share/phpmyadmin
    BLOWFISH=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '${BLOWFISH}'|"\
    -e "s|cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost'|cfg['Servers'][\$i]['host'] = '${MYSQL_HOST}'|"\
    config.sample.inc.php > config.inc.php
    chown -R ${WWW_USER}:${WWW_USER} /usr/share/phpmyadmin

	echo -n "Waiting for mysql server..."
	until mysql -h${MYSQL_HOST} -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -e'show status' > /dev/null 2>&1; do
        sleep 1
        printf '.'
    done
	printf '\n'
	mysql -h${MYSQL_HOST} -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} < /usr/share/phpmyadmin/sql/create_tables.sql
}

if [ -f "/usr/share/phpmyadmin/config.inc.php" ]; then
    echo "Already configured..."
else
	install_phpmyadmin
    setup_phpmyadmin
    echo "Done!"
fi
