FROM alpine

# Install mysql server
RUN apk add --update --no-cache mysql mysql-client

# Enable networking
RUN sed -i -e "/skip-networking/d" /etc/my.cnf.d/mariadb-server.cnf

COPY srcs/init.sh /init.sh

EXPOSE 3306

CMD ["/usr/bin/mysqld_safe", "--datadir=/var/lib/mysql", "--user=root", "--console"]
