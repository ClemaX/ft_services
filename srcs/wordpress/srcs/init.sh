#!/bin/sh

# Fix for ivconv on alpine
export LD_PRELOAD=/usr/lib/preloadable_libiconv.so

# Abort on error
set -e
set -o pipefail

EXT_PORT=5050
PROTOCOL=http

CA_CERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
BEARER="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
STAT_URL="https://kubernetes/api/v1/namespaces/default/services/wordpress"

download_wordpress()
{
	echo "Downloading wordpress..."
	if wp "--path=${WWW_DIR}" core download "--locale=${WP_LOCALE}"; then
		cp "${WWW_DIR}/wp-config-sample.php" "${WWW_DIR}/wp-config.php"
	fi
}

config_wordpress()
{
	echo "Configuring wordpress..."
	wp "--path=${WWW_DIR}" config set DB_NAME "${MYSQL_WP_DATABASE}"
	wp "--path=${WWW_DIR}" config set DB_USER "${MYSQL_WP_USERNAME}"
	wp "--path=${WWW_DIR}" config set DB_PASSWORD "${MYSQL_WP_PASSWORD}" --quiet
	wp "--path=${WWW_DIR}" config set DB_HOST "${MYSQL_HOST}"
}

config_wordpress_postinstall()
{
	echo "Setting website url to '${WP_URL}'..."
	wp "--path=${WWW_DIR}" option update home "${WP_URL}"
	wp "--path=${WWW_DIR}" option update siteurl "${WP_URL}"
}

install_wordpress()
{
	echo "Installing wordpress..."
	wp core install\
		"--path=${WWW_DIR}"\
		"--url=${WP_URL}"\
		"--title=${WP_TITLE}"\
		"--admin_user=${WP_ADMIN_USERNAME}"\
		"--admin_password=${WP_ADMIN_PASSWORD}"\
		"--admin_email=${WP_ADMIN_EMAIL}"
}

create_users()
{
	echo "Creating author '${WP_AUTHOR_USERNAME}'..."
	wp "--path=${WWW_DIR}" user create "${WP_AUTHOR_USERNAME}" "${WP_AUTHOR_EMAIL}" "--user_pass=${WP_AUTHOR_PASSWORD}" --role=author
	echo "Creating editor '${WP_EDITOR_USERNAME}'..."
	wp "--path=${WWW_DIR}" user create "${WP_EDITOR_USERNAME}" "${WP_EDITOR_EMAIL}" "--user_pass=${WP_EDITOR_PASSWORD}" --role=editor
}

# Get external ip if WP_URL is not set
if [[ -z "${WP_URL}" ]]; then
	EXT_IP=$(curl --cacert "${CA_CERT}" -H "Authorization: Bearer ${BEARER}" "${STAT_URL}" | jq -r '.status.loadBalancer.ingress[0].ip')
	WP_URL="${PROTOCOL}://${EXT_IP}:${EXT_PORT}"
fi

if wp "--path=${WWW_DIR}" core is-installed; then
	config_wordpress
	config_wordpress_postinstall
else
	cp -R /wordpress/* "${WWW_DIR}"
	config_wordpress
	install_wordpress
	config_wordpress_postinstall
	create_users
fi

chown -R "${WWW_USER}:${WWW_USER}" "${WWW_DIR}"
echo "Done!"
