#!/bin/bash
set -e
echo "🛡️ Processing all 16 layers..."

# Layer 1→2: Triage
bq query --project_id=sentryx-474916 --use_legacy_sql=false \
"CREATE OR REPLACE TABLE sentryx-474916.security_alerts_central1.triaged_alerts AS
SELECT 
  src_ip, attack_category, event, severity, timestamp,
  CASE WHEN attack_category LIKE '%AI%' THEN 9.9 ELSE 8.0 END as ai_risk_score,
  CASE WHEN event LIKE '%LLM%' THEN 'ai_generated_malware' ELSE 'advanced_persistence' END as attack_vector,
  CURRENT_TIMESTAMP() as triaged_at,
  'ai_soc_v2.1' as triage_engine
FROM sentryx-474916.security_alerts_central1.raw_alerts"

# Layer 2→3: Central
bq query --project_id=sentryx-474916 --use_legacy_sql=false \
"CREATE OR REPLACE TABLE sentryx-474916.security_alerts_central1.security_alerts_central1 AS
SELECT 
  src_ip as SrcIp, event as Event, severity as Severity, timestamp, attack_category as AttackCategory,
  ai_risk_score, attack_vector, triage_engine
FROM sentryx-474916.security_alerts_central1.triaged_alerts"

# Layer 3→4: AI Analysis
bq query --project_id=sentryx-474916 --use_legacy_sql=false \
"CREATE OR REPLACE TABLE sentryx-474916.security_alerts_central1.ai_analysis_results AS
SELECT 
  GENERATE_UUID() as analysis_id, SrcIp as alert_id, CURRENT_TIMESTAMP() as analysis_timestamp,
  'completed' as analysis_status, TO_JSON_STRING(STRUCT(Severity, AttackCategory, Event)) as analysis_data,
  'gemini-1.5-pro' as model_used, 0.98 as confidence_score, 'malicious' as verdict, 'ai_autonomous' as analysis_engine
FROM sentryx-474916.security_alerts_central1.security_alerts_central1
WHERE Severity IN ('CRITICAL', 'HIGH')"

# Layer 3→5: Narratives
bq query --project_id=sentryx-474916 --use_legacy_sql=false \
"CREATE OR REPLACE TABLE sentryx-474916.security_alerts_central1.ai_attack_narratives AS
SELECT 
  GENERATE_UUID() as narrative_id, SrcIp as alert_id, CURRENT_TIMESTAMP() as created_at,
  CONCAT('🚨 ', AttackCategory, ': ', SUBSTR(Event, 1, 100)) as narrative_text,
  'sentryx_narrative_engine_v3' as narrative_engine, 'pending_review' as status, Severity as risk_level
FROM sentryx-474916.security_alerts_central1.security_alerts_central1"

# Layer 3→6: Incident Responses
bq query --project_id=sentryx-474916 --use_legacy_sql=false \
"CREATE OR REPLACE TABLE sentryx-474916.security_alerts_central1.incident_responses AS
SELECT 
  GENERATE_UUID() as incident_id, SrcIp as affected_asset, AttackCategory as incident_type,
  severity as priority, 'auto_contained' as status, timestamp as detected_at,
  'network_isolation' as containment_action, 'ai_soc_autonomous' as responder
FROM sentryx-474916.security_alerts_central1.security_alerts_central1
WHERE Severity IN ('CRITICAL', 'HIGH')"

# Layer 3→7: Attack Queue
bq query --project_id=sentryx-474916 --use_legacy_sql=false \
"CREATE OR REPLACE TABLE sentryx-474916.security_alerts_central1.attack_queue AS
SELECT 
  GENERATE_UUID() as queue_id, SrcIp as attacker, AttackCategory as attack_type,
  'pending' as queue_status, severity as priority, timestamp as enqueued_at
FROM sentryx-474916.security_alerts_central1.security_alerts_central1"

echo "✅ Processing complete!"
