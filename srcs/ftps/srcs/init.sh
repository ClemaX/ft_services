#!/bin/sh

# Abort on error
set -e

echo "Adding FTP user '${FTP_USERNAME}' with home at '${FTP_DIR}'..."
adduser -D ${FTP_USERNAME} -h ${FTP_DIR}
echo "${FTP_USERNAME}:${FTP_PASSWORD}" | chpasswd
echo "Done!"
