#!/bin/bash
set -e

DOMAIN=${1:-$DOMAIN}
EMAIL=${2:-$EMAIL}

echo "Setting up SSL for domain: $DOMAIN"

# Create SSL directory
mkdir -p /etc/ssl/{certs,private}

# Generate self-signed certificate for initial setup
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/key.pem \
    -out /etc/ssl/certs/cert.pem \
    -subj "/CN=$DOMAIN"

echo "SSL setup completed"
