FROM alpine

ENV FTP_DIR=/var/ftp

# Install FTP server
RUN apk add --update --no-cache vsftpd

# Setup configuration files
COPY srcs/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf
RUN touch /etc/vsftpd/chroot_list

COPY srcs/init.sh /init.sh

CMD vsftpd
