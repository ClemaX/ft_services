FROM alpine

# Install mysql server
RUN apk add --update --no-cache mysql
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

EXPOSE 3306

CMD ["/usr/bin/mysqld_safe", "--datadir='/var/lib/mysql'"]

