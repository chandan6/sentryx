import warnings
warnings.filterwarnings("ignore", message="BigQuery Storage module not found")

from google.cloud import bigquery
from tabulate import tabulate
import pandas as pd

# Initialize BigQuery client
client = bigquery.Client()

# Dataset and project info
project = "sentryx-474916"
dataset = "security_alerts_central1"

# 🔹 Only working layers, logically prioritized (L1–L9)
layers = [
    ("Raw Alerts", "raw_alerts"),
    ("Normalized Alerts", "normalized_alerts"),
    ("Attack Queue", "attack_queue"),
    ("Predictive Threats", "predictive_threats"),
    ("ML Predictions", "ml_predictions"),
    ("Forensic Artifacts", "forensic_artifacts"),
    ("AI Attack Narratives", "ai_attack_narratives"),
    ("Incident Responses", "incident_responses"),
    ("AI Defense Rules", "ai_defense_rules"),
]

# Track uniqueness across layers
seen_ips = set()
seen_events = set()

print("\n🔹 SENTRYX — Full 9-Layer Deep Data View (Optimized + Unique Mode) 🔹")
print("=" * 120)

for i, (layer_name, table_name) in enumerate(layers, start=1):
    print(f"\n🧱 L{i} - {layer_name} ({table_name})")
    print("-" * 120)

    query = f"""
    SELECT * FROM `{project}.{dataset}.{table_name}`
    ORDER BY RAND()
    LIMIT 50
    """
    try:
        df = client.query(query).to_dataframe()

        # Skip empty tables
        if df.empty:
            print("⚠️ No data returned (skipped).")
            continue

        # Deduplicate based on IPs and events
        if 'src_ip' in df.columns:
            df = df[~df['src_ip'].isin(seen_ips)]
            seen_ips.update(df['src_ip'].head(10).tolist())

        if 'event' in df.columns:
            df = df[~df['event'].isin(seen_events)]
            seen_events.update(df['event'].head(10).tolist())

        # Limit to 10 rows for clarity
        df = df.head(10)

        # Display as clean table
        print(tabulate(df, headers="keys", tablefmt="grid", showindex=False))

    except Exception as e:
        print(f"⚠️ Error reading {table_name}: {str(e)}")

print("\n✅ Completed 9-layer unified scan (unique entries only, top 10 per layer).")
