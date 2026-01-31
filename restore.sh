#!/bin/bash

# --- CONFIGURATION ---
GRAFANA_URL="http://admin:MySecurePassword123!@localhost:3000"
BUCKET_NAME="grafana-recovery"
RESTORE_DIR="./restore_temp"

echo "--- STARTING RECOVERY ---"

# 1. Download from S3
echo "⬇️  Downloading backup from S3..."
mkdir -p $RESTORE_DIR
aws s3 cp s3://$BUCKET_NAME/grafana-backup/ $RESTORE_DIR --recursive

# 2. Wait for Grafana
echo "⏳ Waiting for Grafana to wake up..."
until curl -s -o /dev/null "$GRAFANA_URL/api/health"; do
  echo "   - Grafana is sleeping... retrying in 5s"
  sleep 5
done
echo "✅ Grafana is ONLINE!"

# 3. Restore Data Sources
echo "🔌 Restoring Data Sources..."
if [ -f "$RESTORE_DIR/datasources.json" ]; then
    jq -c '.[]' $RESTORE_DIR/datasources.json | while read i; do
        curl -s -X POST -H "Content-Type: application/json" -d "$i" $GRAFANA_URL/api/datasources
    done
    echo "   - Data sources restored (duplicates are ignored)."
else
    echo "   ⚠️ No datasources.json found in backup."
fi

# 4. Restore Dashboards (FIXED ID ISSUE)
echo "📊 Restoring Dashboards..."
for file in $RESTORE_DIR/dashboard_*.json; do
    if [ -e "$file" ]; then
        # FIX: We remove the internal 'id' so Grafana creates a fresh entry
        jq '. | del(.id) | {"dashboard": ., "overwrite": true}' "$file" > temp_payload.json
        
        # Send to Grafana
        curl -s -X POST -H "Content-Type: application/json" -d @temp_payload.json $GRAFANA_URL/api/dashboards/db
        echo "   - Restored $(basename $file)"
    fi
done

# 5. Cleanup
rm -rf $RESTORE_DIR temp_payload.json
echo "🎉 RECOVERY COMPLETE! Go check the UI."
