#!/usr/bin/env python3
import time, random
from google.cloud import bigquery
import vertexai
from vertexai.generative_models import GenerativeModel

PROJECT = 'sentryx-474916'
DATASET = 'security_alerts_central1'
MODEL_NAME = "gemini-2.0-flash-exp"

vertexai.init(project=PROJECT, location="us-central1")
bq_client = bigquery.Client(project=PROJECT)

print("📖 Layer 5: AI Attack Narratives (⚠️ $0.002/narrative)")

def generate_narrative(alert_row):
    try:
        src_ip = str(alert_row.get('src_ip', 'unknown'))
        category = str(alert_row.get('AttackCategory', 'N/A'))
        event = str(alert_row.get('Event', 'N/A'))[:400]
        
        prompt = f"""You are a SOC analyst. Write a professional investigation narrative:

**Incident**: {category}
**Source**: {src_ip}
**Details**: {event}

Include: Executive Summary, Timeline, Impact, IOCs, Remediation."""

        response = gemini.generate_content(
            prompt,
            generation_config={"temperature": 0.2, "max_output_tokens": 1000}
        )
        
        return response.text.strip()
        
    except Exception as e:
        if "429" in str(e):
            print("  ⚠️  Rate limit - cooling down for 10 seconds...")
            time.sleep(10)
        return None

# Model check
try:
    test_model = GenerativeModel(MODEL_NAME)
    test_model.generate_content("Test", generation_config={"max_output_tokens": 10})
    print("✅ Model ready")
except Exception as e:
    print(f"❌ Model failed: {e}")
    exit(1)

gemini = GenerativeModel(MODEL_NAME)

alerts = bq_client.query(f"""
    SELECT src_ip, AttackCategory, Event
    FROM `{PROJECT}.{DATASET}.security_alerts_central1`
    WHERE severity = 'CRITICAL'
    LIMIT 3
""").result()

narratives = []
success_count = 0

for i, alert in enumerate(alerts):
    print(f"  Generating narrative {i+1}...")
    text = generate_narrative(dict(alert))
    
    if text:
        narratives.append({
            'narrative_id': alert['src_ip'],
            'narrative_text': text,
            'narrative_engine': MODEL_NAME,
            'status': 'ai_generated'
        })
        success_count += 1
        time.sleep(5 + random.uniform(0, 3))  # 5-8 seconds for narratives
    else:
        time.sleep(6)

if narratives:
    errors = bq_client.insert_rows_json(f"{PROJECT}.{DATASET}.ai_attack_narratives_real", narratives)
    if not errors:
        print(f"  ✅ Generated {success_count} narratives: ${success_count*0.002:.3f}")
