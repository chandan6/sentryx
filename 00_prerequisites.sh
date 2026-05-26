#!/bin/bash
set -e

PROJECT="sentryx-474916"
DATASET="security_alerts_central1"
YOUR_EMAIL="chandankelur26@gmail.com"

echo "🔧 SENTRYX: Full Pipeline Setup..."

# Enable APIs
echo "→ Enabling Vertex AI API..."
gcloud services enable aiplatform.googleapis.com --project=$PROJECT

echo "→ Enabling BigQuery API..."
gcloud services enable bigquery.googleapis.com --project=$PROJECT

# Grant IAM Permissions
echo "→ Granting IAM permissions..."
gcloud projects add-iam-policy-binding $PROJECT \
  --member="user:$YOUR_EMAIL" \
  --role="roles/aiplatform.user"

gcloud projects add-iam-policy-binding $PROJECT \
  --member="user:$YOUR_EMAIL" \
  --role="roles/bigquery.dataEditor"

gcloud projects add-iam-policy-binding $PROJECT \
  --member="user:$YOUR_EMAIL" \
  --role="roles/bigquery.jobUser"

# Upgrade SDK
echo "→ Upgrading Vertex AI SDK..."
pip install --upgrade google-cloud-aiplatform vertexai

# Clean tables
echo "→ Cleaning previous error records..."
bq query --project_id=$PROJECT --nouse_legacy_sql "
TRUNCATE TABLE \`$PROJECT.$DATASET.ai_analysis_results_real\`;
TRUNCATE TABLE \`$PROJECT.$DATASET.ai_attack_narratives_real\`;
TRUNCATE TABLE \`$PROJECT.$DATASET.ml_predictions_real\`;
"

# Create all layers 7-16 tables
echo "→ Creating layers 7-16 tables..."
bq query --project_id=$PROJECT --nouse_legacy_sql "
CREATE TABLE IF NOT EXISTS \`$PROJECT.$DATASET.threat_intelligence_real\` (ioc STRING, ioc_type STRING, threat_level STRING, source_feed STRING, first_seen TIMESTAMP, last_seen TIMESTAMP);
CREATE TABLE IF NOT EXISTS \`$PROJECT.$DATASET.automated_response_real\` (response_id STRING, action_taken STRING, success BOOLEAN, execution_time FLOAT64, created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP());
CREATE TABLE IF NOT EXISTS \`$PROJECT.$DATASET.forensic_artifacts_real\` (artifact_id STRING, artifact_type STRING, collection_status STRING, storage_path STRING, created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP());
CREATE TABLE IF NOT EXISTS \`$PROJECT.$DATASET.cross_cloud_telemetry_real\` (telemetry_id STRING, cloud_provider STRING, anomalies_detected INT64, affected_services ARRAY<STRING>, created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP());
CREATE TABLE IF NOT EXISTS \`$PROJECT.$DATASET.user_anomalies_real\` (user_id STRING, risk_score FLOAT64, anomaly_type STRING, confidence FLOAT64, created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP());
CREATE TABLE IF NOT EXISTS \`$PROJECT.$DATASET.policy_drift_real\` (drift_id STRING, policy_type STRING, drift_severity STRING, remediation_required BOOLEAN, created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP());
CREATE TABLE IF NOT EXISTS \`$PROJECT.$DATASET.threat_graph_links_real\` (graph_node STRING, node_type STRING, connected_iocs ARRAY<STRING>, graph_score FLOAT64, created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP());
CREATE TABLE IF NOT EXISTS \`$PROJECT.$DATASET.ai_defense_deploys_real\` (defense_id STRING, defense_type STRING, deployment_status STRING, coverage_rate FLOAT64, created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP());
CREATE TABLE IF NOT EXISTS \`$PROJECT.$DATASET.compliance_report_real\` (report_id STRING, framework STRING, findings ARRAY<STRING>, compliance_score FLOAT64, generated_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP());
CREATE TABLE IF NOT EXISTS \`$PROJECT.$DATASET.executive_summary_real\` (summary_id STRING, summary_text STRING, total_incidents INT64, critical_count INT64, generated_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP());
"

echo "✅ Setup complete!"

# Test model
echo "→ Testing model..."
python3 -c "
import vertexai
from vertexai.generative_models import GenerativeModel
vertexai.init(project='$PROJECT', location='us-central1')
model = GenerativeModel('gemini-2.0-flash-exp')
print('✅ Model ready')
"