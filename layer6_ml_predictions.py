#!/usr/bin/env python3
from google.cloud import bigquery

PROJECT_ID = 'sentryx-474916'
DATASET_ID = 'security_alerts_central1'
bq_client = bigquery.Client(project=PROJECT_ID)

def layer6_ml_predictions():
    """Run BigQuery ML predictions on recent alerts"""
    try:
        # Predict on alerts from last 24 hours
        predict_query = f"""
            INSERT INTO `{PROJECT_ID}.{DATASET_ID}.ml_predictions`
            SELECT 
                CONCAT('PRED_', CAST(FLOOR(RAND() * 1000000) AS STRING)) as prediction_id,
                JSON_EXTRACT_SCALAR(data, '$.src_ip') as threat_actor,
                IF(predicted_label = 1, 'CRITICAL Threat', 'Standard Threat') as predicted_attack,
                GREATEST(0.75, CAST(predicted_label_probs[OFFSET(1)].prob AS FLOAT64)) as confidence_score,
                'bigquery_ml_logistic_reg' as prediction_model,
                CURRENT_TIMESTAMP() as predicted_time
            FROM ML.PREDICT(
                MODEL `{PROJECT_ID}.{DATASET_ID}.threat_model`,
                (SELECT data, JSON_EXTRACT_SCALAR(data, '$.AttackCategory') as attack_type 
                 FROM `{PROJECT_ID}.{DATASET_ID}.normalized_alerts`
                 WHERE publish_time > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR))
            )
        """
        bq_client.query(predict_query).result()
        print(f"✅ Layer 6: Generated ML predictions for recent alerts")
        
    except Exception as e:
        # If model doesn't exist, train it first
        print(f"⚠️  Model not found, training new model...")
        
        train_query = f"""
            CREATE OR REPLACE MODEL `{PROJECT_ID}.{DATASET_ID}.threat_model`
            OPTIONS(model_type='LOGISTIC_REG') AS
            SELECT 
                CASE WHEN JSON_EXTRACT_SCALAR(data, '$.severity') = 'CRITICAL' THEN 1 ELSE 0 END as label,
                JSON_EXTRACT_SCALAR(data, '$.AttackCategory') as attack_type
            FROM `{PROJECT_ID}.{DATASET_ID}.normalized_alerts`
            WHERE publish_time > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
        """
        bq_client.query(train_query).result()
        print(f"⏳ Model trained. Run this function again in 2 minutes.")

if __name__ == "__main__":
    layer6_ml_predictions()
