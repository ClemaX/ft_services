FROM alpine

ENV WWW_USER=www-data
ENV WWW_DIR=/var/www/localhost

# Install dependencies
RUN apk add --update --no-cache nginx openssh

# Setup WWW user with home at WWW dir
RUN adduser -D -h"${WWW_DIR}" -G"${WWW_USER}" "${WWW_USER}"\
	&& chown -R "${WWW_USER}:${WWW_USER}" /var/lib/nginx

# Setup Nginx config
RUN rm /etc/nginx/conf.d/default.conf
COPY srcs/nginx/localhost.conf /etc/nginx/conf.d/localhost.conf
COPY srcs/nginx/nginx.conf /etc/nginx/nginx.conf

# Generate SSH host keys
RUN ssh-keygen -A

COPY srcs/init.sh /init.sh
COPY srcs/liveness.sh /liveness.sh

# Set index
COPY srcs/index.html "${WWW_DIR}"

EXPOSE 80 22

CMD sh init.sh && /usr/sbin/sshd && nginx
