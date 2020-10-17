FROM alpine

# MySQL Settings
ENV MYSQL_HOST="mysql"

# PMA Settings
ARG PMA_VERSION="5.0.1"

ENV PMA_FILENAME="phpMyAdmin-${PMA_VERSION}-all-languages"
ENV	PMA_URL="https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/${PMA_FILENAME}.zip"
ENV	PMA_KEY_URL="https://files.phpmyadmin.net/phpmyadmin.keyring"

ENV PMA_BLOWFISH=""

# Installation Settings
ENV WWW_USER=www-data
ENV WWW_DIR="/var/www/phpmyadmin"
ENV PMA_DIR="/usr/share/phpmyadmin"

# PHP FPM Settings
ENV PHP_FPM_LISTEN_MODE="0660"
ENV PHP_MEMORY_LIMIT="512M"
ENV PHP_MAX_UPLOAD="50M"
ENV PHP_MAX_FILE_UPLOAD="200"
ENV PHP_MAX_POST="100M"
ENV PHP_DISPLAY_ERRORS="On"
ENV PHP_DISPLAY_STARTUP_ERRORS="On"
ENV PHP_ERROR_REPORTING="E_COMPILE_ERROR\|E_RECOVERABLE_ERROR\|E_ERROR\|E_CORE_ERROR"
ENV PHP_CGI_FIX_PATHINFO=0

# Install dependencies
RUN apk add --update --no-cache curl gnupg jq mysql-client nginx php7-fpm\
	php7-mbstring php7-common php7-iconv php7-session php7-json\
	php7-gd php7-curl php7-xml php7-mysqli php7-imap php7-pdo php7-pdo_mysql\
	php7-soap php7-xmlrpc php7-posix php7-mcrypt php7-gettext php7-ldap php7-ctype php7-dom

# Setup WWW user
RUN adduser -D "-G${WWW_USER}" "${WWW_USER}"\
	&& chown -R "${WWW_USER}:${WWW_USER}" /var/lib/nginx\
	&& mkdir -p "${WWW_DIR}"\
	&& ln -s "${PMA_DIR}" "${WWW_DIR}/phpmyadmin"

# Download PMA
RUN wget -qO /phpmyadmin.zip "${PMA_URL}"\
	&& curl "${PMA_KEY_URL}" | gpg --import\
	&& curl "${PMA_URL}.asc" | gpg --verify - /phpmyadmin.zip\
	&& unzip -q /phpmyadmin.zip -d /tmp\
	&& rm /phpmyadmin.zip\
	&& mv "/tmp/${PMA_FILENAME}" "${PMA_DIR}"

# Setup Nginx config
RUN rm -f /etc/nginx/conf.d/default.conf
COPY srcs/nginx/phpmyadmin.conf /etc/nginx/conf.d/phpmyadmin.conf
COPY srcs/nginx/nginx.conf /etc/nginx/nginx.conf

# Setup PHP config
RUN sed -i /etc/php7/php-fpm.d/www.conf -e "s|;listen.owner\s*=\s*nobody|listen.owner = ${WWW_USER}|g"\
	-e "s|;listen.group\s*=\s*nobody|listen.group = ${WWW_USER}|g"\
	-e "s|;listen.mode\s*=\s*0660|listen.mode = ${PHP_FPM_LISTEN_MODE}|g"\
	-e "s|user\s*=\s*nobody|user = ${WWW_USER}|g"\
	-e "s|group\s*=\s*nobody|group = ${WWW_USER}|g"\
	-e "s|;log_level\s*=\s*notice|log_level = notice|g" /etc/php7/php-fpm.d/www.conf

COPY srcs/entrypoint.sh /entrypoint.sh

EXPOSE 5000

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "nginx" ]
