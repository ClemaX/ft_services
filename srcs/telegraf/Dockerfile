FROM alpine

# Install dependencies
RUN apk add --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted telegraf

COPY srcs/telegraf.conf /etc/telegraf/telegraf.conf

CMD telegraf --config /etc/telegraf/telegraf.conf