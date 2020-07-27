FROM alpine

# Name of the Telegraf-InfluxDB Grafana-DataSource
ENV DS_INFLUXK8S=InfluxDB

# InfluxDB configuration
# ENV INFLUXDB_URL=http://influxdb:8086
# ENV INFLUXDB_DATABASE=monitoring
# ENV INFLUXDB_USERNAME=grafana
# ENV INFLUXDB_PASSWORD=grafana

# Grafana data directory
ENV GRAFANA_DIR=/var/lib/grafana

# Grafana configuration
# ENV GF_SECURITY_ADMIN_USER=admin
# ENV GF_SECURITY_ADMIN_PASSWORD=admin

# TLS
# ENV GF_SERVER_PROTOCOL=https
# ENV GF_SERVER_CERT_FILE=tls.crt
# ENV GF_SERVER_CERT_KEY=tls.key

# Install dependencies
RUN apk add --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted grafana

COPY srcs/defaults.ini /defaults.ini
COPY srcs/datasources.yaml /datasources.yaml
COPY srcs/dashboards.yaml /dashboards.yaml
COPY srcs/dashboards /dashboards
COPY srcs/init.sh /init.sh

CMD grafana-server --homepath ${GRAFANA_DIR}