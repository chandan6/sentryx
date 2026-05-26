#!/bin/bash
# Monitor Pub/Sub ingestion in real-time
PROJECT_ID="sentryx-474916"
SUBSCRIPTION_ID="sentryx-bq-streaming-sub"
echo "📡 Monitoring Pub/Sub messages (Press Ctrl+C to stop)..."
gcloud pubsub subscriptions tail "$SUBSCRIPTION_ID" --project="$PROJECT_ID" --limit=10
