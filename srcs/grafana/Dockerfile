FROM alpine

# Install dependencies
RUN apk add --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted grafana

COPY srcs/defaults.ini /defaults.ini
COPY srcs/datasources.yaml /datasources.yaml
COPY srcs/init.sh /init.sh

CMD grafana-server --homepath ${GRAFANA_DIR}