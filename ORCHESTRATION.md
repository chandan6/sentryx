# SENTRYX Deployment & Orchestration

SENTRYX is not just a collection of scripts; it is an end-to-end autonomous pipeline. The architecture is orchestrated locally via **WSL2 (Ubuntu 22.04)**, creating a seamless DevSecOps bridge to Google Cloud Platform.

## The Local-to-Cloud Bridge
The system utilizes the **Google Cloud SDK** installed on the WSL instance, providing authenticated, low-latency access to cloud services:

1. **Environment:** WSL2 Linux (local) acts as the control plane.
2. **Authentication:** Managed via `gcloud auth application-default login`, ensuring secure service-to-service communication.
3. **Data Plane:** - **Ingestion:** Local subscriber scripts listen to `Pub/Sub` topics configured in GCP.
   - **AI Orchestration:** `Vertex AI` endpoints are accessed via the `google-cloud-aiplatform` SDK.
   - **Storage/ML:** `BigQuery` acts as the unified data warehouse, with `ML.PREDICT` executing natively in the cloud while triggered by local logic.

## Why this Architecture?
By running the orchestration plane locally in WSL, I maintain high-speed access to debugging logs and local development tools (VS Code, Git, PyTest), while offloading the resource-heavy compute (LLM inference and ML model training) to GCP. This hybrid approach minimizes operational cost while maximizing deployment velocity.
