#!/bin/bash

# --- CONFIGURATION ---
GRAFANA_URL="http://admin:MySecurePassword123!@localhost:3000"
BUCKET_NAME="grafana-recovery"  # <--- REPLACE THIS
BACKUP_DIR="./backup_temp"

echo "--- STARTING BACKUP ---"

# 1. Prepare temp directory
mkdir -p $BACKUP_DIR

# 2. Backup Data Sources (The Connection)
echo "🔌 Exporting Data Sources..."
curl -s $GRAFANA_URL/api/datasources \
  | jq '.' > $BACKUP_DIR/datasources.json

# 3. Backup Dashboards (The Visuals)
echo "📊 Exporting Dashboards..."
# Get list of all dashboard UIDs
for uid in $(curl -s $GRAFANA_URL/api/search | jq -r '.[].uid'); do
    # Download specific dashboard JSON
    curl -s $GRAFANA_URL/api/dashboards/uid/$uid \
      | jq '.dashboard' > $BACKUP_DIR/dashboard_$uid.json
    echo "   - Saved dashboard: $uid"
done

# 4. Upload to S3 (The Vault)
echo "🚀 Uploading to S3..."
aws s3 cp $BACKUP_DIR s3://$BUCKET_NAME/grafana-backup/ --recursive

# 5. Cleanup
rm -rf $BACKUP_DIR
echo "✅ BACKUP COMPLETE! Files are in S3."

