FROM alpine

# Install Nginx
RUN apk add --update --no-cache nginx
# Setup Nginx config
COPY srcs/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443
