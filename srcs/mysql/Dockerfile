FROM alpine

# MySQL Database Location
ENV MYSQL_DATA_DIR="/var/lib/mysql"
# MySQL Initial Tables Location
ENV MYSQL_TABLES_DIR="/etc/mysql/tables"
# Max Tries when connecting to MySQL
ENV MYSQL_MAX_RETRY="5"
# The User running the Daemon
ENV MYSQLD_USER="root"

# init-secrets
ENV MYSQL_WP_DATABASE="wordpressDbName"

ENV MYSQL_ROOT_PASSWORD="rootUserPassword"

ENV MYSQL_WP_USERNAME="wordpressUser"
ENV MYSQL_WP_PASSWORD="wordpressPassword"

ENV MYSQL_PMA_USERNAME="pmaUser"
ENV MYSQL_PMA_PASSWORD="pmaPassword"

# Install mysql server
RUN apk add --update --no-cache mysql mysql-client\
    && mkdir -p "${MYSQL_TABLES_DIR}"

# Add init table for phpmyadmin
ADD https://raw.githubusercontent.com/phpmyadmin/phpmyadmin/master/sql/create_tables.sql "${MYSQL_TABLES_DIR}"

# Enable networking
RUN sed -i -e "/skip-networking/d" /etc/my.cnf.d/mariadb-server.cnf

COPY srcs/entrypoint.sh /entrypoint.sh

EXPOSE 3306

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "/usr/bin/mysqld_safe", "--datadir=${MYSQL_DATA_DIR}", "--user=${MYSQLD_USER}", "--console" ]
