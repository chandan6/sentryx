#!/bin/bash
set -e
echo "🛡️ Ingesting 20 Advanced Attacks..."

bq query --project_id=sentryx-474916 --use_legacy_sql=false \
"INSERT INTO sentryx-474916.security_alerts_central1.raw_alerts (src_ip, attack_category, event, severity, timestamp)
VALUES 
  ('198.51.100.45', 'AI-Assisted Ransomware', 'AI LLM generated polymorphic ransomware evading EDR', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.78', 'LLM Prompt Injection', 'Malicious prompt injected into GPT-4 code review bot', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('192.0.2.156', 'Kubernetes RBAC Escalation', 'Exploited webhook to grant cluster-admin role', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('198.51.100.23', 'AI Cloud Exploit', 'AI created Terraform exploit bypassing Sentinel policies', 'HIGH', CURRENT_TIMESTAMP()),
  ('203.0.113.201', 'Cosign Bypass', 'Compromised Notary service allowed unsigned containers', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('192.0.2.89', 'GitHub Actions Poisoning', 'Malicious action exfiltrated GITHUB_TOKENs', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('198.51.100.167', 'Container Escape', 'Escape via CVE-2024-21626 with eBPF rootkit', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.54', 'K8s Secret Exfiltration', 'Stole etcd encryption key from control plane', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('192.0.2.234', 'Serverless Supply Chain', 'Compromised Lambda layer used by 500+ functions', 'HIGH', CURRENT_TIMESTAMP()),
  ('198.51.100.112', 'Metadata SSRF', 'Extracted GCP service account token via SSRF', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.92', 'Terraform Tampering', 'Modified tfstate to inject invisible admin IAM bindings', 'HIGH', CURRENT_TIMESTAMP()),
  ('192.0.2.78', 'AI Phishing Bypass', 'AI created hyper-personalized phishing emails', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('198.51.100.201', 'Cross-Cloud Lateral', 'Compromised Azure identity to assume AWS/GCP roles', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.123', 'SBOM Poisoning', 'Injected malicious dependency into CycloneDX SBOM', 'HIGH', CURRENT_TIMESTAMP()),
  ('192.0.2.167', 'Sigstore Abuse', 'Abused Fulcio CA for malicious code certificate', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('198.51.100.78', 'CSI Driver Exploit', 'Mounted host filesystem via compromised CSI driver', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.201', 'Workload Identity Hijack', 'Hijacked workload federation across 50+ accounts', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('192.0.2.234', 'Git Submodule Backdoor', 'Rootkit payload in pre-commit hooks', 'HIGH', CURRENT_TIMESTAMP()),
  ('198.51.100.145', 'Registry Manifest Poison', 'MITM replaced container registry manifests', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.67', 'WAF Rule Tampering', 'Disabled Cloud Armor DDoS protection for 4 hours', 'HIGH', CURRENT_TIMESTAMP())"

echo "✅ Ingestion complete: $(bq query --project_id=sentryx-474916 --format=csv --quiet 'SELECT COUNT(*) FROM sentryx-474916.security_alerts_central1.raw_alerts') rows"
