#!/bin/sh

# Exit on error
set -e

# Check if mysql is installed
if [ -d "/var/lib/mysql/mysql" ]; then
	echo "Already initialized."
else
	echo "Initializing..."
	# Init mysql
	mysql_install_db --user=root --datadir=/var/lib/mysql

	# Start mysqld
	/usr/bin/mysqld_safe --skip-networking --user=root --datadir=/var/lib/mysql &

	# Wait for mysqld and update password
	mysqladmin -w5 -u root password ${MYSQL_ROOT_PASSWORD}

	# Init databases
	mysql -e "CREATE DATABASE phpmyadmin;\
	CREATE USER ${MYSQL_PHP_USERNAME} IDENTIFIED BY '${MYSQL_PHP_PASSWORD}';\
	GRANT ALL PRIVILEGES ON phpmyadmin.* TO '${MYSQL_PHP_USERNAME}';\
	CREATE DATABASE ${MYSQL_WP_DATABASE}; CREATE USER ${MYSQL_WP_USERNAME} IDENTIFIED BY '${MYSQL_WP_PASSWORD}';\
	GRANT ALL PRIVILEGES ON ${MYSQL_WP_DATABASE}.* TO '${MYSQL_WP_USERNAME}'"
	echo "Done!"
fi