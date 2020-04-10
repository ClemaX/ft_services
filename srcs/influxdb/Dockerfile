FROM alpine

# Enable basic HTTP authentication
ENV INFLUXDB_HTTP_AUTH_ENABLED=true

# Install dependencies
RUN apk add --update --no-cache influxdb

EXPOSE 8086

CMD influxd
