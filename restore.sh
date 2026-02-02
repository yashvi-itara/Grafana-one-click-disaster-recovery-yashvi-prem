#!/bin/bash
set -e
 
echo "===== GRAFANA RESTORE STARTED ====="
 
# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "❌ .env file not found"
  exit 1
fi
 
# Validate required variables
if [ -z "$S3_BUCKET_NAME" ]; then
  echo "❌ S3_BUCKET_NAME not set in .env"
  exit 1
fi
 
# This MUST match docker-compose generated volume name
GRAFANA_VOLUME="grafana-one-click-disaster-recovery-yashvi-prem_grafana-storage"
 
# Get latest backup from S3
LATEST_BACKUP=$(aws s3 ls s3://$S3_BUCKET_NAME/ | sort | tail -n 1 | awk '{print $4}')
 
if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ No backup found in S3 bucket"
  exit 1
fi
 
echo "Latest backup found: $LATEST_BACKUP"
 
# Download backup
aws s3 cp s3://$S3_BUCKET_NAME/$LATEST_BACKUP ./
 
# Create Grafana volume (idempotent)
docker volume create $GRAFANA_VOLUME >/dev/null
 
echo "Restoring data into Grafana volume..."
 
# Restore backup into the volume
docker run --rm \
  -v $GRAFANA_VOLUME:/var/lib/grafana \
  -v $(pwd):/backup \
  ubuntu \
  bash -c "cd /var/lib/grafana && tar xzf /backup/$LATEST_BACKUP --strip-components=3"
 
echo "Restore completed successfully"
echo "===== GRAFANA RESTORE COMPLETED ====="
