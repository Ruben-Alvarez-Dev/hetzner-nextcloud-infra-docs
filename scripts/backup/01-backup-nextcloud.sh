#!/bin/bash
#=============================================================================
# Script: Nextcloud Backup
# Description: Creates complete backup of Nextcloud data and database
# Author: Ruben Alvarez
# License: MIT
#=============================================================================

set -e

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/mnt/storage-ruben/backups}"
NEXTCLOUD_DIR="/var/www/nextcloud"
DB_NAME="nextcloud"
DB_USER="root"
RETENTION_DAYS=30

# Timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="nextcloud_backup_${TIMESTAMP}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }

# Create backup directory
mkdir -p "${BACKUP_DIR}/${BACKUP_NAME}"

# Enable maintenance mode
log_info "Enabling Nextcloud maintenance mode..."
sudo -u www-data php "${NEXTCLOUD_DIR}/occ" maintenance:mode --on

# Backup database
log_info "Backing up MySQL database..."
mysqldump --single-transaction -h localhost -u "${DB_USER}" "${DB_NAME}" | \
    gzip > "${BACKUP_DIR}/${BACKUP_NAME}/database.sql.gz"

# Backup Nextcloud data directory
log_info "Backing up Nextcloud data..."
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}/data.tar.gz" \
    -C "$(dirname ${NEXTCLOUD_DIR})" \
    "$(basename ${NEXTCLOUD_DIR})/data"

# Backup Nextcloud config
log_info "Backing up configuration..."
cp -r "${NEXTCLOUD_DIR}/config" "${BACKUP_DIR}/${BACKUP_NAME}/config"

# Create backup manifest
log_info "Creating backup manifest..."
cat > "${BACKUP_DIR}/${BACKUP_NAME}/manifest.json" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "version": "$(php ${NEXTCLOUD_DIR}/occ status --output=json 2>/dev/null | jq -r '.versionstring' || echo 'unknown')",
    "database_size": "$(du -h ${BACKUP_DIR}/${BACKUP_NAME}/database.sql.gz | cut -f1)",
    "data_size": "$(du -h ${BACKUP_DIR}/${BACKUP_NAME}/data.tar.gz | cut -f1)"
}
EOF

# Disable maintenance mode
log_info "Disabling Nextcloud maintenance mode..."
sudo -u www-data php "${NEXTCLOUD_DIR}/occ" maintenance:mode --off

# Clean old backups
log_info "Cleaning backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_DIR}" -type d -name "nextcloud_backup_*" -mtime +${RETENTION_DAYS} -exec rm -rf {} \; 2>/dev/null || true

# Create latest symlink
ln -sfn "${BACKUP_DIR}/${BACKUP_NAME}" "${BACKUP_DIR}/latest"

log_info "Backup completed: ${BACKUP_DIR}/${BACKUP_NAME}"
