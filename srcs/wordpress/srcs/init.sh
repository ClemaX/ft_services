#!/bin/sh

# Fix for ivconv on alpine
export LD_PRELOAD=/usr/lib/preloadable_libiconv.so

# Abort on error
set -e
set -o pipefail

download_wordpress()
{
	echo "Downloading wordpress..."
	wp --path=${WWW_DIR} core download --locale=${WP_LOCALE}
	cp ${WWW_DIR}/wp-config-sample.php ${WWW_DIR}/wp-config.php
}

config_wordpress()
{
	echo "Configuring wordpress..."
	wp --path=${WWW_DIR} config set DB_NAME ${MYSQL_WP_DATABASE}
	wp --path=${WWW_DIR} config set DB_USER ${MYSQL_WP_USERNAME}
	wp --path=${WWW_DIR} config set DB_PASSWORD ${MYSQL_WP_PASSWORD} --quiet
	wp --path=${WWW_DIR} config set DB_HOST ${MYSQL_HOST}
}

install_wordpress() {
	echo "Installing wordpress..."
	wp core install\
		--path=${WWW_DIR}\
		--url=${WP_URL}\
		--title=${WP_TITLE}\
		--admin_user=${WP_ADMIN_USERNAME}\
		--admin_password=${WP_ADMIN_PASSWORD}\
		--admin_email=${WP_ADMIN_EMAIL}
}

wp --path=${WWW_DIR} core is-installed\
	&& config_wordpress\
	|| download_wordpress && config_wordpress && install_wordpress

chown -R ${WWW_USER}:${WWW_USER} ${WWW_DIR}
echo "Done!"
