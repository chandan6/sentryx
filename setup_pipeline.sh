#!/bin/bash
set -e

PROJECT="sentryx-474916"
DATASET="security_alerts_central1"

echo "🚀 SentryX Pipeline Setup..."

# 1. Enable Vertex AI API
echo "Enabling Vertex AI API..."
gcloud services enable aiplatform.googleapis.com --project=$PROJECT

# 2. Create BigQuery tables
echo "Creating BigQuery tables..."
bq query --project_id=$PROJECT --nouse_legacy_sql "
CREATE OR REPLACE TABLE \`$PROJECT.$DATASET.ai_analysis_results_real\` (
  alert_id STRING,
  analysis_data STRING,
  model_used STRING,
  confidence_score FLOAT64,
  verdict STRING,
  analysis_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE \`$PROJECT.$DATASET.ai_attack_narratives_real\` (
  narrative_id STRING,
  narrative_text STRING,
  narrative_engine STRING,
  status STRING,
  created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE \`$PROJECT.$DATASET.ml_predictions_real\` (
  threat_actor STRING,
  predicted_attack STRING,
  confidence_score FLOAT64,
  prediction_model STRING,
  predicted_time STRING
);
"

echo "✅ Setup complete! All tables created."
