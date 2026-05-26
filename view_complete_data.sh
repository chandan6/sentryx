#!/bin/bash
clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  🛡️  SENTRYX: 16 Layers Defense Platform                      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

for TABLE in security_alerts_central1 raw_alerts ai_attack_narratives attack_queue ai_analysis_results incident_responses narratives ai_triage_results ai_defense_rules threat_graph_links predictive_threats sentryx_soar user_anomalies policy_drift forensic_artifacts soc_reports; do
  echo "══════════════════════════════════════════════════════════════════"
  ROWS=$(bq query --project_id=sentryx-474916 --format=csv --quiet "SELECT COUNT(*) FROM \`security_alerts_central1.$TABLE\`")
  echo "TABLE: $TABLE | Total Intelligence Records: $ROWS"
  echo "══════════════════════════════════════════════════════════════════"
  echo ""
  
  # Show complete data vertically (full text, no truncation)
  bq query --project_id=sentryx-474916 "SELECT * FROM \`security_alerts_central1.$TABLE\` LIMIT 20"
  
  echo ""
  echo "┌────────────────────────────────────────────────────────────────┐"
  echo "│ 📸 Capture Screenshot | Press Enter for Next Layer            │"
  echo "└────────────────────────────────────────────────────────────────┘"
  read -p ""
  clear
done

echo "✅ SENTRYX: 16 Layers Defense Platform - Complete!"
