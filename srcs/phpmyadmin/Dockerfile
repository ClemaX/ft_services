FROM alpine

ARG phpmyadmin_version="5.0.1"

ENV WWW_USER=www-data
ENV PHP_FPM_LISTEN_MODE="0660"
ENV PHP_MEMORY_LIMIT="512M"
ENV PHP_MAX_UPLOAD="50M"
ENV PHP_MAX_FILE_UPLOAD="200"
ENV PHP_MAX_POST="100M"
ENV PHP_DISPLAY_ERRORS="On"
ENV PHP_DISPLAY_STARTUP_ERRORS="On"
ENV PHP_ERROR_REPORTING="E_COMPILE_ERROR\|E_RECOVERABLE_ERROR\|E_ERROR\|E_CORE_ERROR"
ENV PHP_CGI_FIX_PATHINFO=0

# Install Packages
RUN apk add --update --no-cache nginx php7-fpm php7-mysql php7-mbstring

# Setup WWW user
RUN adduser -D -G$WWW_USER $WWW_USER\
	&& mkdir -p /var/www/phpmyadmin\
	&& chown -R $WWW_USER:$WWW_USER /var/www/phpmyadmin\
	&& chown -R $WWW_USER:$WWW_USER /var/lib/nginx

# Setup Nginx config
RUN rm /etc/nginx/conf.d/default.conf
COPY srcs/nginx/phpmyadmin.conf /etc/nginx/conf.d/phpmyadmin.conf
COPY srcs/nginx/nginx.conf /etc/nginx/nginx.conf

# Setup PHP config
RUN sed -i /etc/php7/php-fpm.d/www.conf -e "s|;listen.owner\s*=\s*nobody|listen.owner = ${WWW_USER}|g"\
	-e "s|;listen.group\s*=\s*nobody|listen.group = ${WWW_USER}|g"\
	-e "s|;listen.mode\s*=\s*0660|listen.mode = ${PHP_FPM_LISTEN_MODE}|g"\
	-e "s|user\s*=\s*nobody|user = ${WWW_USER}|g"\
	-e "s|group\s*=\s*nobody|group = ${WWW_USER}|g"\
	-e "s|;log_level\s*=\s*notice|log_level = notice|g" /etc/php7/php-fpm.d/www.conf

# Setup phpmyadmin
RUN wget -qO /tmp/phpmyadmin.zip https://files.phpmyadmin.net/phpMyAdmin/${phpmyadmin_version}/phpMyAdmin-${phpmyadmin_version}-all-languages.zip
RUN cd /tmp && unzip phpmyadmin.zip && rm -f phpmyadmin.zip\
	&& mv phpMyAdmin-${phpmyadmin_version}-all-languages /usr/share/phpmyadmin\
	&& chown -R www-data:www-data /usr/share/phpmyadmin\
	&& ln -s /usr/share/phpmyadmin /var/www/phpmyadmin
RUN cd /usr/share/phpmyadmin\
	&& sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '${BLOWFISH}'|" config.sample.inc.php > config.inc.php

EXPOSE 5050

CMD php-fpm7 && nginx