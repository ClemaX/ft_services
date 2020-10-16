#!/bin/sh

# Abort on error
set -e

CA_CERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
BEARER="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
STAT_URL="https://kubernetes/api/v1/namespaces/default/services/nginx"

setup_phpmyadmin()
{
	STAT_DATA="$(curl --cacert "${CA_CERT}" -H "Authorization: Bearer ${BEARER}" "${STAT_URL}")"
	EXT_IP="$(echo "${STAT_DATA}" | jq -r '.status.loadBalancer.ingress[0].ip')"

	echo "Setting up phpMyAdmin..."
	cd "${PMA_DIR}"

	sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '${PMA_BLOWFISH}'|"\
	-e "s|cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost'|cfg['Servers'][\$i]['host'] = '${MYSQL_HOST}'|"\
	config.sample.inc.php > config.inc.php

	echo "Setting 'PmaAbsoluteUri' to 'https://${EXT_IP}/phpmyadmin/'..."
	echo "\$cfg['PmaAbsoluteUri'] = 'https://${EXT_IP}/phpmyadmin/';" >> config.inc.php

	chown -R "${WWW_USER}:${WWW_USER}" "${PMA_DIR}"
	echo "Done!"
}

setup_phpmyadmin

echo "Starting php-fpm..."
php-fpm7

exec $(eval echo "${@}")
