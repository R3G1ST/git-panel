#!/bin/bash
set -e

BACKUP_DIR="/opt/xferant-vpn/backups"
DATE=$(date +%Y%m%d_%H%M%S)
CONTAINER_NAME="xferant-vpn-postgres-1"

echo "Starting backup..."

mkdir -p $BACKUP_DIR

# Backup database
docker exec $CONTAINER_NAME pg_dump -U xferant_user xferant_vpn > $BACKUP_DIR/db_$DATE.sql

# Backup configurations
tar -czf $BACKUP_DIR/config_$DATE.tar.gz config/ 

echo "Backup completed:"
echo "- Database: $BACKUP_DIR/db_$DATE.sql"
echo "- Configs: $BACKUP_DIR/config_$DATE.tar.gz"
