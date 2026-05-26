#!/bin/bash
# Standardize alert data for AI processing
PROJECT="sentryx-474916"

echo "🔄 Normalizing raw alerts for AI processing..."

bq query --project_id=$PROJECT --nouse_legacy_sql --quiet "
CREATE OR REPLACE TABLE \`$PROJECT.security_alerts_central1.security_alerts_central1\` AS
SELECT 
  SrcIp as SrcIp,
  Event as Event,
  Severity as Severity,
  CAST(timestamp AS TIMESTAMP) as timestamp,
  AttackCategory as attack_category,
  SHA256(SrcIp || Event) as alert_id,
  CURRENT_TIMESTAMP() as processing_time
FROM \`$PROJECT.security_alerts_central1.raw_alerts\`
WHERE timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
"

echo "✅ Processed $(bq query --project_id=$PROJECT --nouse_legacy_sql --format=csv "SELECT COUNT(*) FROM \`$PROJECT.security_alerts_central1.security_alerts_central1\`" | tail -n1) alerts"
