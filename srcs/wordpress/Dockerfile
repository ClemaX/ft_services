FROM alpine

ENV WWW_USER=www-data
ENV WWW_DIR=/var/www/wordpress

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
RUN apk add --update --no-cache nginx php7-fpm php7-mysqli php7-mbstring

# Setup WWW user
RUN adduser -D -G$WWW_USER $WWW_USER\
	&& mkdir -p $WWW_DIR\
	&& chown -R $WWW_USER:$WWW_USER $WWW_DIR\
	&& chown -R $WWW_USER:$WWW_USER /var/lib/nginx

# Setup Nginx config
RUN rm /etc/nginx/conf.d/default.conf
COPY srcs/nginx/wordpress.conf /etc/nginx/conf.d/wordpress.conf
COPY srcs/nginx/nginx.conf /etc/nginx/nginx.conf

# Setup PHP config
RUN sed -i /etc/php7/php-fpm.d/www.conf -e "s|;listen.owner\s*=\s*nobody|listen.owner = ${WWW_USER}|g"\
	-e "s|;listen.group\s*=\s*nobody|listen.group = ${WWW_USER}|g"\
	-e "s|;listen.mode\s*=\s*0660|listen.mode = ${PHP_FPM_LISTEN_MODE}|g"\
	-e "s|user\s*=\s*nobody|user = ${WWW_USER}|g"\
	-e "s|group\s*=\s*nobody|group = ${WWW_USER}|g"\
	-e "s|;log_level\s*=\s*notice|log_level = notice|g" /etc/php7/php-fpm.d/www.conf

# Setup wordpress
RUN wget -qO /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
RUN cd /tmp && tar xzf wordpress.tar.gz && rm -f wordpress.tar.gz\
	&& mv wordpress/* $WWW_DIR && rmdir wordpress
RUN cd $WWW_DIR\
	&& sed -e "s/database_name_here/${mysql_wp_db}/"\
	-e "s/username_here/${mysql_wp_user}/"\
	-e "s/password_here/${mysql_wp_pw}/" wp-config-sample.php > wp-config.php

EXPOSE 5050

CMD php-fpm7 && nginx