#!/bin/sh

# Abort on error
set -e

echo "Adding FTP user '${FTP_USERNAME}' with home at '${FTP_DIR}'..."
adduser -D ${FTP_USERNAME} -h ${FTP_DIR}
passwd ${FTP_USERNAME} -d ${FTP_PASSWORD}
echo "Done!"
