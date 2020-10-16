#!/bin/sh

# Exit on error
set -e

install_mysql()
{
	echo "Installing mysql db at '${MYSQL_DATA_DIR}'..."
	# Init mysql
	mysql_install_db "--user=${MYSQLD_USER}" "--datadir=${MYSQL_DATA_DIR}"

	# Start mysqld
	echo "Starting mysqld..."
	/usr/bin/mysqld_safe --skip-networking "--user=${MYSQLD_USER}" "--datadir=${MYSQL_DATA_DIR}" &

	# Wait for mysqld and update password
	mysqladmin "-w${MYSQL_MAX_RETRY}" "-u${MYSQLD_USER}" password "${MYSQL_ROOT_PASSWORD}"
}

init_database()
{
	cd "${MYSQL_TABLES_DIR}"
	for SCRIPT in *.sql; do
		echo "Executing '${SCRIPT}'..."
		mysql < "${SCRIPT}"
	done

	echo "Creating wordpress database '${MYSQL_WP_DATABASE}' with admin '${MYSQL_WP_USERNAME}'..."
	mysql <<-EOF
		CREATE DATABASE \`${MYSQL_WP_DATABASE}\`;
		CREATE USER \`${MYSQL_WP_USERNAME}\` IDENTIFIED BY '${MYSQL_WP_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_WP_DATABASE}\`.* TO \`${MYSQL_WP_USERNAME}\`;
	EOF

	echo "Creating mysql superadmin '${MYSQL_PMA_USERNAME}'..."
	mysql <<-EOF
		CREATE USER \`${MYSQL_PMA_USERNAME}\` IDENTIFIED BY '${MYSQL_PMA_PASSWORD}';
		GRANT ALL PRIVILEGES ON *.* TO \`${MYSQL_PMA_USERNAME}\`;
	EOF
}

# Check if mysql is installed
if [ -d "${MYSQL_DATA_DIR}/mysql" ]; then
	echo "Already initialized!"
else
	install_mysql
	init_database
	echo "Stopping mysqld..."
	kill %1
	echo "Done!"
fi

exec $(eval echo "${@}")
