#!/bin/bash
# Check streaming health
PROJECT="sentryx-474916"

echo "🔍 Checking Pub/Sub → BigQuery streaming health..."

# Check BigQuery streaming inserts (last 5 minutes)
bq query --project_id=$PROJECT --nouse_legacy_sql --format=pretty "
SELECT 
  COUNT(*) as alerts_received,
  COUNT(DISTINCT SrcIp) as unique_sources,
  MIN(timestamp) as earliest,
  MAX(timestamp) as latest
FROM \`sentryx-474916.security_alerts_central1.raw_alerts\`
WHERE timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 5 MINUTE)
"
