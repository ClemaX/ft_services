FROM alpine

# Wordpress Language and Region
ENV WP_LOCALE=en_US

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

# Install dependencies
RUN apk add --update --no-cache curl jq nginx php7 php7-fpm php7-json php7-zlib php7-xml\
	php7-pdo php7-phar php7-openssl php7-pdo_mysql php7-mysqli php7-mysqlnd\
	php7-gd php7-mcrypt php7-curl php7-opcache php7-ctype php7-intl php7-bcmath\
	php7-dom php7-xmlreader php7-tokenizer php7-iconv php7-exif php7-fileinfo\
	php7-mbstring php7-pecl-imagick php7-zip\
	&& apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted gnu-libiconv 

# Install wp-cli
RUN wget -qO /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x /usr/local/bin/wp

# Download Wordpress
RUN wp --path=/wordpress core download --locale=${WP_LOCALE}\
	&& cp /wordpress/wp-config-sample.php /wordpress/wp-config.php

# Setup WWW user
RUN adduser -D -G${WWW_USER} ${WWW_USER}\
	&& chown -R ${WWW_USER}:${WWW_USER} /var/lib/nginx

# Setup php-fpm config
RUN sed -i /etc/php7/php-fpm.d/www.conf\
	-e "s|;listen.owner\s*=\s*nobody|listen.owner = ${WWW_USER}|g"\
	-e "s|;listen.group\s*=\s*nobody|listen.group = ${WWW_USER}|g"\
	-e "s|;listen.mode\s*=\s*0660|listen.mode = ${PHP_FPM_LISTEN_MODE}|g"\
	-e "s|user\s*=\s*nobody|user = ${WWW_USER}|g"\
	-e "s|group\s*=\s*nobody|group = ${WWW_USER}|g"\
	-e "s|;log_level\s*=\s*notice|log_level = notice|g"\
	/etc/php7/php-fpm.d/www.conf

# Setup nginx config
RUN rm /etc/nginx/conf.d/default.conf
COPY srcs/nginx/wordpress.conf /etc/nginx/conf.d/wordpress.conf
COPY srcs/nginx/nginx.conf /etc/nginx/nginx.conf

COPY srcs/init.sh /init.sh
COPY srcs/liveness.sh /liveness.sh

EXPOSE 5050

CMD php-fpm7 && nginx
