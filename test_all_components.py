#!/usr/bin/env python3
import sys
from google.cloud import bigquery
import vertexai
from vertexai.generative_models import GenerativeModel

PROJECT = 'sentryx-474916'
DATASET = 'security_alerts_central1'

print("🔍 Testing SentryX Components...")

# Test BigQuery
try:
    bq = bigquery.Client(project=PROJECT)
    tables = list(bq.list_tables(f"{PROJECT}.{DATASET}"))
    print(f"✅ BigQuery: {len(tables)} tables")
except Exception as e:
    print(f"❌ BigQuery: {e}")
    sys.exit(1)

# Test Gemini
try:
    vertexai.init(project=PROJECT, location="us-central1")
    model = GenerativeModel("gemini-2.0-flash-exp")
    resp = model.generate_content("Test", generation_config={"max_output_tokens": 10})
    print("✅ Gemini: Model working")
except Exception as e:
    print(f"❌ Gemini: {str(e)[:80]}")
    sys.exit(1)

# Test tables
for table in ['ai_analysis_results_real', 'ai_attack_narratives_real', 'ml_predictions_real']:
    try:
        bq.get_table(f"{PROJECT}.{DATASET}.{table}")
        print(f"✅ Table: {table}")
    except Exception as e:
        print(f"❌ Table {table}: {e}")
        sys.exit(1)

print("\n🎉 All systems ready!")