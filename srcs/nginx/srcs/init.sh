#!/bin/sh

# Abort on error
set -e

echo "Setting password for ${WWW_USER}..."
echo "${WWW_USER}:${SSH_PASSWORD}" | chpasswd
echo "Done!"
