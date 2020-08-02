#!/bin/sh

# Abort on error
set -e

CA_CERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
BEARER=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
STAT_URL=https://kubernetes/api/v1/namespaces/default/services/ftp
FTP_CONF=/etc/vsftpd/vsftpd.conf

# Init FTP user
echo "Adding FTP user '${FTP_USERNAME}' with home at '${FTP_DIR}'..."
adduser -D ${FTP_USERNAME} -h ${FTP_DIR}
echo "${FTP_USERNAME}:${FTP_PASSWORD}" | chpasswd

# Init FTP config
EXT_IP=$(curl --cacert "${CA_CERT}" -H "Authorization: Bearer ${BEARER}" "${STAT_URL}" | jq -r '.status.loadBalancer.ingress[0].ip')
echo "Setting PASV IP to '${EXT_IP}'..."
sed -i "${FTP_CONF}" -e "s|EXT_IP|${EXT_IP}|g" "${FTP_CONF}"
echo "Done!"
