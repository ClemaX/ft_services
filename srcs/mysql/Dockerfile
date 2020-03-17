FROM alpine

# Install mysql server
RUN apk add --update --no-cache mysql mysql-client

COPY srcs/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 3306

CMD ["/usr/bin/mysqld_safe", "--datadir=/var/lib/mysql", "--user=root", "--console"]
