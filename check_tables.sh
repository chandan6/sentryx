#!/bin/bash
PROJECT="sentryx-474916"
DATASET="security_alerts_central1"

echo "🔍 Checking existing tables in $PROJECT:$DATASET..."
bq ls --project_id=$PROJECT --dataset=$DATASET --format=pretty 2>/dev/null || echo "❌ Dataset not found or no permissions"

echo ""
echo "📊 Getting table details..."
bq query --project_id=$PROJECT --nouse_legacy_sql "
SELECT 
  table_id,
  row_count,
  ROUND(size_bytes/1024/1024,2) as size_mb,
  type
FROM \`$PROJECT.$DATASET.__TABLES__\`
ORDER BY table_id
"