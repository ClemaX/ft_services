#!/bin/sh

# Start mysqld
/usr/bin/mysqld_safe --skip-networking --user=root --datadir=/var/lib/mysql &

# Wait for mysql and update password
mysqladmin -w15 -u root password ${MYSQL_ROOT_PASSWORD}

# Init databases
mysql -e "CREATE DATABASE phpmyadmin;\
	CREATE USER ${MYSQL_PHP_USERNAME} IDENTIFIED BY '${MYSQL_PHP_PASSWORD}';\
	GRANT ALL PRIVILEGES ON phpmyadmin.* TO '${MYSQL_PHP_USERNAME}';\
	CREATE DATABASE ${MYSQL_WP_DATABASE}; CREATE USER ${MYSQL_WP_USERNAME} IDENTIFIED WITH mysql_native_password BY '${MYSQL_WP_PASSWORD}';\
	GRANT ALL PRIVILEGES ON ${MYSQL_WP_DATABASE}.* TO '${MYSQL_WP_USERNAME}'"