#!/usr/bin/env python3
import json, time, random
from google.cloud import bigquery
import vertexai
from vertexai.generative_models import GenerativeModel

PROJECT = 'sentryx-474916'
DATASET = 'security_alerts_central1'
MODEL_NAME = "gemini-2.0-flash-exp"

vertexai.init(project=PROJECT, location="us-central1")
bq_client = bigquery.Client(project=PROJECT)

print("🔍 Layer 4: AI Deep Analysis (⚠️ $0.001/alert)")

def analyze_threat(alert_row):
    try:
        event = str(alert_row.get('Event', 'N/A'))[:400]
        severity = str(alert_row.get('severity', 'N/A'))
        category = str(alert_row.get('AttackCategory', 'N/A'))
        
        prompt = f"""You are a cybersecurity analyst. Analyze this alert and return ONLY JSON:

**Event**: {event}
**severity**: {severity}
**Category**: {category}

Return: {{"verdict": "malicious|benign|suspicious", "confidence": 0.85, "attack_vector": "network|phishing|malware", "containment_steps": ["block_ip", "isolate_endpoint"], "risk_score": 7}}"""

        response = gemini.generate_content(
            prompt, 
            generation_config={"temperature": 0.1, "max_output_tokens": 500}
        )
        
        text = response.text.strip().replace('```json', '').replace('```', '').strip()
        return json.loads(text)
        
    except Exception as e:
        if "429" in str(e):
            print("  ⚠️  Rate limit hit - cooling down for 10 seconds...")
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
    SELECT src_ip, Event, severity, AttackCategory
    FROM `{PROJECT}.{DATASET}.security_alerts_central1`
    WHERE severity = 'CRITICAL'
    LIMIT 5
""").result()

results = []
success_count = 0

for i, alert in enumerate(alerts):
    print(f"  Processing alert {i+1}...")
    analysis = analyze_threat(dict(alert))
    
    if analysis:
        results.append({
            'alert_id': alert['src_ip'],
            'analysis_data': json.dumps(analysis),
            'model_used': MODEL_NAME,
            'confidence_score': float(analysis.get('confidence', 0)),
            'verdict': analysis.get('verdict', 'error')
        })
        success_count += 1
        time.sleep(3 + random.uniform(0, 2))  # 3-5 seconds between requests
    else:
        time.sleep(5)

if results:
    errors = bq_client.insert_rows_json(f"{PROJECT}.{DATASET}.ai_analysis_results_real", results)
    if not errors:
        print(f"  ✅ Analyzed {success_count} threats: ${success_count*0.001:.3f}")
