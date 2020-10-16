FROM alpine

ENV FTP_DIR="/var/ftp"

# Install FTP server
RUN apk add --update --no-cache tini curl jq vsftpd

# Create FTP Directory
RUN mkdir -p "${FTP_DIR}"

# Setup configuration files
COPY srcs/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf
RUN touch /etc/vsftpd/chroot_list && touch /var/log/vsftpd.log

COPY srcs/entrypoint.sh /entrypoint.sh

EXPOSE 21 1024-1027

ENTRYPOINT [ "/sbin/tini", "--", "/entrypoint.sh"]

CMD [ "vsftpd", "${FTP_CONF}" ]
