#!/bin/bash
set -e

echo "Updating Xferant VPN..."

# Pull latest changes
git pull origin main

# Rebuild and restart services
docker-compose down
docker-compose build
docker-compose up -d

echo "Update completed successfully"
