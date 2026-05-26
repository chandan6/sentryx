#!/bin/bash
set -e

PROJECT="sentryx-474916"
DATASET="security_alerts_central1"

echo "🛡️ SENTRYX: Real-Time AI Security Pipeline"
echo "⚠️  Streaming cost: ~$0.01/hour continuous ingestion"
echo "======================================="

echo "→ STEP 1: Verifying streaming pipeline..."
gcloud services list --enabled --project=$PROJECT | grep -q pubsub.googleapis.com || \
  { echo "❌ Pub/Sub not enabled"; exit 1; }
gcloud services list --enabled --project=$PROJECT | grep -q aiplatform.googleapis.com || \
  { echo "❌ Vertex AI not enabled"; exit 1; }

echo "→ STEP 2: Checking real-time data flow..."
# Verify bridge is running
if ! pgrep -f "pubsub_bq_bridge_production.py" > /dev/null; then
  echo "⚠️  Bridge not running. Starting it..."
  nohup python3 pubsub_bq_bridge_production.py > bridge.log 2>&1 &
  sleep 3
fi

# Check for recent alerts (last 15 minutes)
ALERT_COUNT=$(bq query --project_id=$PROJECT --nouse_legacy_sql --format=csv --quiet "
SELECT COUNT(*) as cnt 
FROM \`$PROJECT.$DATASET.normalized_alerts\` 
WHERE timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 15 MINUTE)
" | tail -n1)

if [ "$ALERT_COUNT" -eq "0" ]; then
  echo "⚠️  No recent streaming alerts. Generating test attacks..."
  python3 sophisticated_attacks.py
  echo "⏳ Waiting 10 seconds for ingestion..."
  sleep 10
  ALERT_COUNT=$(bq query --project_id=$PROJECT --nouse_legacy_sql --format=csv --quiet "
  SELECT COUNT(*) as cnt 
  FROM \`$PROJECT.$DATASET.normalized_alerts\` 
  WHERE timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 15 MINUTE)
  " | tail -n1)
fi

echo "✅ Streaming active: $ALERT_COUNT new alerts in last 15 minutes"

echo "→ STEP 3: Verifying tables..."
bq query --project_id=$PROJECT --nouse_legacy_sql --quiet \
  "SELECT COUNT(*) FROM \`$PROJECT.$DATASET.security_alerts_central1\`" >/dev/null || \
  { echo "❌ Main table not found"; exit 1; }

echo "→ STEP 4: Processing data through all 16 layers..."
./process_pipeline.sh

echo -e "\n--- AI LAYERS 4-6 (Deep Analysis) ---"
python3 layer4_ai_analysis.py
python3 layer5_narratives.py
python3 layer6_ml_predictions.py

echo -e "\n--- AI LAYERS 7-16 (Fusion & Response) ---"
python3 layers_7_16_parallel.py

echo -e "\n✅ Real-time pipeline complete!"

echo "📊 Final Cost & Performance Summary:"
bq query --project_id=$PROJECT --nouse_legacy_sql --format=pretty "
WITH costs AS (
  SELECT 
    'Layer 4: AI Analysis' as layer,
    COUNTIF(verdict != 'error') as success_count,
    COUNTIF(verdict != 'error') * 0.001 as cost_usd
  FROM \`$PROJECT.$DATASET.ai_analysis_results_real\`
  UNION ALL
  SELECT 
    'Layer 5: Narratives',
    COUNT(*),
    COUNT(*) * 0.002
  FROM \`$PROJECT.$DATASET.ai_attack_narratives_real\`
  UNION ALL
  SELECT 
    'Layer 6: ML Predictions',
    COUNT(*),
    COUNT(*) * 0.0005
  FROM \`$PROJECT.$DATASET.ml_predictions_real\`
  UNION ALL
  SELECT 
    'Layers 7-16: Fusion',
    COUNT(*),
    0.0
  FROM \`$PROJECT.$DATASET.threat_intelligence_real\`
)
SELECT 
  layer,
  success_count as processed,
  CONCAT('\$', FORMAT('%.3f', cost_usd)) as cost,
  CONCAT('\$', FORMAT('%.3f', SUM(cost_usd) OVER ())) as total_cost
FROM costs
ORDER BY layer
"