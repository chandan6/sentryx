#!/bin/bash
bq query --project_id=sentryx-474916 "
INSERT INTO \`security_alerts_central1.raw_alerts\` (src_ip, attack_category, event, severity, timestamp)
VALUES 
  ('198.51.100.45', 'AI-Assisted Ransomware', 'AI LLM generated polymorphic ransomware that evades EDR. Encrypted 500GB production data. BTC ransom demand bypassed revenue prediction model.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.78', 'LLM Prompt Injection Supply Chain', 'Malicious prompt injected into GPT-4 powered code review bot. Bot approved backdoor in 5 production repos before detection.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('192.0.2.156', 'Kubernetes RBAC Privilege Escalation', 'Exploited mutating admission webhook to grant cluster-admin role. Deployed daemonset for persistent access.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('198.51.100.23', 'AI-Generated Cloud Infrastructure Exploit', 'AI created Terraform exploit that bypassed Sentinel policies. Created 50 shadow admin accounts in 3 cloud providers.', 'HIGH', CURRENT_TIMESTAMP()),
  ('203.0.113.201', 'Cosign Signature Bypass Supply Chain', 'Compromised Notary service allowed unsigned container images. Malicious image deployed to 200+ production GKE nodes.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('192.0.2.89', 'GitHub Actions CI/CD Poisoning', 'Malicious action exfiltrated GITHUB_TOKENs from 30 repos. Used tokens to push backdoors to npm packages and Docker images.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('198.51.100.167', 'Container Escape via eBPF Rootkit', 'Container escape using CVE-2024-21626. Installed eBPF rootkit on host. Exfiltrated /etc/shadow from 15 nodes.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.54', 'Kubernetes Secret Decryption Exfiltration', 'Stole etcd encryption key from control plane. Decrypted 1200+ Kubernetes secrets including cloud credentials.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('192.0.2.234', 'Serverless Function Supply Chain Attack', 'Compromised Lambda layer used by 500+ functions. Injected crypto miner and data stealer into all invocations.', 'HIGH', CURRENT_TIMESTAMP()),
  ('198.51.100.112', 'Cloud Metadata Service SSRF Exploit', 'SSRF attack extracted GCP service account token from metadata service. Token had owner role on entire project.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.92', 'Terraform State File Tampering', 'Malicious provider modified tfstate to inject fake resources. Created 10 invisible admin IAM bindings bypassing IaC detection.', 'HIGH', CURRENT_TIMESTAMP()),
  ('192.0.2.78', 'AI-Generated Phishing Bypass MFA', 'AI created hyper-personalized phishing emails. Bypassed Google 2FA via stolen session cookies from compromised Chrome extension.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('198.51.100.201', 'Cross-Cloud Lateral Movement', 'Compromised Azure Managed Identity. Used federated credentials to assume AWS role and access GCP service account.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.123', 'Software Bill of Materials Poisoning', 'Injected malicious dependency into SBOM. Dependency masqueraded as legitimate package in CycloneDX format.', 'HIGH', CURRENT_TIMESTAMP()),
  ('192.0.2.167', 'Sigstore Fulcio Certificate Abuse', 'Abused Sigstone Fulcio CA to obtain legitimate certificate for malicious code. Certificate passed all supply chain validations.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('198.51.100.78', 'Kubernetes CSI Driver Privilege Escalation', 'Exploited CSI driver to mount host filesystem. Modified kubelet configuration for persistent cluster access.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.201', 'Cloud Workload Identity Federation Hijack', 'Hijacked workload identity federation between GCP and AWS. Assumed 50+ service accounts across projects.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('192.0.2.234', 'Git Submodule Backdoor Injection', 'Injected malicious submodule that loads rootkit on git clone. Submodule payload executes pre-commit hooks stealing credentials.', 'HIGH', CURRENT_TIMESTAMP()),
  ('198.51.100.145', 'Container Registry Manifest Poisoning', 'MITM attack on container registry replaced image manifests. Redirected pulls to attacker-controlled images with embedded malware.', 'CRITICAL', CURRENT_TIMESTAMP()),
  ('203.0.113.67', 'Cloud Armor WAF Rule Tampering', 'Compromised GCP Cloud Armor rules via stolen admin token. Disabled DDoS protection for 4 hours during active attack.', 'HIGH', CURRENT_TIMESTAMP())
"

echo "✅ Ingested 20 ultra-advanced attacks!"
echo "📊 New total: $(bq query --project_id=sentryx-474916 --format=csv --quiet 'SELECT COUNT(*) FROM \`security_alerts_central1.raw_alerts\`') rows in raw_alerts"
