#!/bin/bash
set -e
 
echo "===== GRAFANA BACKUP STARTED ====="
 
# VARIABLES
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
BACKUP_FILE="grafana-backup-$TIMESTAMP.tar.gz"
S3_BUCKET="grafana-recovery-bucket"
 
# CHECK AWS ACCESS
echo "Checking AWS identity..."
aws sts get-caller-identity
 
# CHECK GRAFANA CONTAINER
if ! docker ps | grep -q grafana; then
  echo "Grafana container not running!"
  exit 1
fi
 
# CREATE BACKUP INSIDE CONTAINER
echo "Creating backup inside Grafana container..."
docker exec grafana tar czf /tmp/$BACKUP_FILE /var/lib/grafana
 
# COPY BACKUP TO HOST
echo "Copying backup from container to host..."
docker cp grafana:/tmp/$BACKUP_FILE ./
 
# VERIFY FILE EXISTS
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backup file not found on host!"
  exit 1
fi
 
# UPLOAD TO S3
echo "Uploading backup to S3..."
aws s3 cp $BACKUP_FILE s3://$S3_BUCKET/
 
echo "Backup uploaded successfully!"
 
# CLEANUP
rm -f $BACKUP_FILE
docker exec grafana rm -f /tmp/$BACKUP_FILE
 
echo "===== GRAFANA BACKUP COMPLETED ====="
