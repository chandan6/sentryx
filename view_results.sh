#!/bin/bash
# View SENTRYX results
PROJECT_ID="sentryx-474916"
DATASET_ID="security_alerts_central1"

echo "🎯 SENTRYX PIPELINE RESULTS"
echo "==========================="

# Wait for data
echo "⏳ Checking for fresh data..."
bq query --nouse_legacy_sql --format=pretty "
SELECT 
  COUNT(*) as total_alerts,
  MIN(detected_timestamp) as earliest,
  MAX(detected_timestamp) as latest
FROM \`$PROJECT_ID.$DATASET_ID.normalized_alerts\`
WHERE detected_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR);
"

echo ""
echo "📊 Attack Breakdown:"
bq query --nouse_legacy_sql --format=pretty "
SELECT 
  alert_type,
  COUNT(*) as count,
  AVG(ai_confidence_score) as avg_score,
  COUNTIF(threat_intel_match=TRUE) as intel_matches,
  ARRAY_AGG(DISTINCT src_ip IGNORE NULLS LIMIT 3) as sample_ips
FROM \`$PROJECT_ID.$DATASET_ID.normalized_alerts\`
WHERE detected_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
GROUP BY alert_type
ORDER BY count DESC;
"

echo ""
echo "🚨 Top Critical Threats:"
bq query --nouse_legacy_sql --format=pretty "
SELECT 
  detected_timestamp,
  alert_type,
  src_ip,
  ai_confidence_score,
  threat_intel_match
FROM \`$PROJECT_ID.$DATASET_ID.normalized_alerts\`
WHERE detected_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
ORDER BY ai_confidence_score DESC
LIMIT 10;
"
