#!/usr/bin/env python3
import os, sys, json, base64, signal, time, logging
from typing import List, Dict
from google.cloud import pubsub_v1, bigquery
from google.api_core.exceptions import ServiceUnavailable

logging.basicConfig(level=logging.INFO, format="%(asctime)s | %(levelname)s | %(message)s")

PROJECT = "sentryx-474916"
TOPIC = f"projects/{PROJECT}/topics/security-alerts-clean"
SUB_NAME = f"projects/{PROJECT}/subscriptions/security-alerts-clean-sub"
BQ_TABLE = f"{PROJECT}.security_alerts_central1.normalized_alerts"

BATCH_SIZE = 50  # Increased for production
FLUSH_SECS = 5

bq = bigquery.Client(project=PROJECT)
subscriber = pubsub_v1.SubscriberClient()

pending: List[Dict] = []

def ensure_resources():
    """Ensure subscription exists"""
    try:
        subscriber.create_subscription(
            request={"name": SUB_NAME, "topic": TOPIC, "ack_deadline_seconds": 60}
        )
        logging.info(f"🆕 Created subscription: {SUB_NAME}")
    except Exception as e:
        logging.info(f"✅ Subscription ready: {SUB_NAME}")

def flush_rows():
    """Batch insert to BigQuery"""
    global pending
    if not pending:
        return
    try:
        errors = bq.insert_rows_json(BQ_TABLE, pending)
        if errors:
            logging.error(f"❌ BQ errors: {errors}")
        else:
            logging.info(f"✅ Inserted {len(pending)} rows")
            pending = []
    except Exception as e:
        logging.error(f"❌ BQ error: {e}")

def callback(message):
    """Process Pub/Sub messages"""
    global pending
    
    try:
        # Parse message
        data = json.loads(message.data.decode('utf-8'))
        
        # Map fields to schema
        row = {
            "src_ip": str(data.get("src_ip", "")),
            "Event": str(data.get("Event", "")),
            "severity": str(data.get("severity", "")),
            "timestamp": str(data.get("timestamp", "")),
            "AttackCategory": str(data.get("AttackCategory", ""))
        }
        
        pending.append(row)
        
        # Batch flush
        if len(pending) >= BATCH_SIZE:
            flush_rows()
            
        message.ack()
    except Exception as e:
        logging.error(f"❌ Message error: {e}")
        message.nack()

def main():
    ensure_resources()
    logging.info(f"🚀 Bridge running: {SUB_NAME} → {BQ_TABLE}")
    
    with subscriber:
        future = subscriber.subscribe(SUB_NAME, callback=callback)
        try:
            while True:
                time.sleep(FLUSH_SECS)
                flush_rows()
        except KeyboardInterrupt:
            logging.info("⏳ Shutting down...")
            flush_rows()
            future.cancel()

if __name__ == "__main__":
    main()