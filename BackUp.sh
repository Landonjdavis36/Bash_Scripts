#!/bin/bash
SOURCE_DIR="/path/to/source/directory"
BACKUP_DIR="/path/to/backup/directory"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
tar -czf "$BACKUP_DIR/backup_$TIMESTAMP.tar.gz" "$SOURCE_DIR"
echo "Backup completed successfully."
