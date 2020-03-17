#!/bin/sh

WWW_USER=www-data
WWW_DIR=/var/www/wordpress

# Abort on error
set -e

# Check if wordpress is installed
if [ -d ${WWW_DIR}/wp-admin ]; then
	echo "Already initialized."
else
	echo "Initializing..."
	# Setup wordpress
	cd /tmp
	wget -qO wordpress.tar.gz https://wordpress.org/latest.tar.gz
	tar xzf wordpress.tar.gz
	rm -f wordpress.tar.gz
	mkdir -p ${WWW_DIR}
	mv wordpress/* ${WWW_DIR}
	rmdir wordpress
	chown -R ${WWW_USER}:${WWW_USER} ${WWW_DIR}
	cd ${WWW_DIR}

	sed -e "s/database_name_here/${MYSQL_WP_DATABASE}/"\
	-e "s/username_here/${MYSQL_WP_USERNAME}/"\
	-e "s/password_here/${MYSQL_WP_PASSWORD}/"\
	-e "s/localhost/${MYSQL_HOST}/"\
	wp-config-sample.php > wp-config.php
	echo "Done!"
fi
