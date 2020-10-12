FROM alpine

ENV FTP_DIR=/var/ftp

# Install FTP server
RUN apk add --update --no-cache curl jq vsftpd

# Setup configuration files
COPY srcs/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf
RUN touch /etc/vsftpd/chroot_list && touch /var/log/vsftpd.log

COPY srcs/init.sh /init.sh

EXPOSE 21 1024-1027

CMD sh init.sh && vsftpd /etc/vsftpd/vsftpd.conf
