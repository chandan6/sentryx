import json
import os
import csv
from pydantic import BaseModel
from langchain_google_vertexai import VertexAI
from langchain_core.prompts import PromptTemplate
from google import genai
from google.genai import types


# --- 1. Define structured JSON schema for AI response ---
class TriageSchema(BaseModel):
    threat_level: str
    mitre_tactic: str
    mitre_technique: str
    remediation_summary: str

# Rebuild to prevent PydanticUserError
TriageSchema.model_rebuild()


# --- 2. Create Vertex AI model ---
def create_llm_chain():
    print("Initializing Gemini 2.5 Flash model on Vertex AI...")
    try:
        llm = VertexAI(
            model_name="gemini-2.5-flash",
            temperature=0.1,
            max_output_tokens=1024
        )
        return llm
    except Exception as e:
        print(f"Error initializing Vertex AI LLM: {e}")
        print("Run this command first:\n  gcloud auth application-default login")
        return None


# --- 3. Use Google GenAI client for structured output ---
def triage_alert_structured(log_data_str: str):
    """
    Uses the Gemini 2.5 Pro model to analyze the log and return structured JSON.
    """
    client = genai.Client(vertexai=True, project="sentryx-474916", location="us-central1")

    full_prompt = f"""
    You are an expert cybersecurity analyst. Analyze the following Falco log and map it
    to the MITRE ATT&CK framework. Return ONLY valid JSON following this schema:
    {{
      "threat_level": "CRITICAL, HIGH, MEDIUM, or LOW",
      "mitre_tactic": "MITRE Tactic Name",
      "mitre_technique": "TXXXX.XXX",
      "remediation_summary": "One-sentence fix summary"
    }}

    Log Data:
    {log_data_str}
    """

    response = client.models.generate_content(
        model="gemini-2.5-pro",
        contents=[full_prompt],
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=TriageSchema
        )
    )
    return response.text


# --- 4. Save AI triage result to CSV ---
def save_triage_result(output_path: str, log_data: dict, ai_response: str):
    try:
        clean_json = ai_response.strip().replace("```json", "").replace("```", "")
        ai_data = json.loads(clean_json)

        fieldnames = [
            'timestamp', 'rule', 'priority', 'details',
            'ai_decision', 'mitre_tactic', 'mitre_technique', 'remediation'
        ]

        row_data = {
            'timestamp': log_data.get('time'),
            'rule': log_data.get('rule'),
            'priority': log_data.get('priority'),
            'details': log_data.get('output'),
            'ai_decision': ai_data.get('threat_level'),
            'mitre_tactic': ai_data.get('mitre_tactic'),
            'mitre_technique': ai_data.get('mitre_technique'),
            'remediation': ai_data.get('remediation_summary')
        }

        file_exists = os.path.isfile(output_path)
        with open(output_path, 'a', newline='') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            if not file_exists:
                writer.writeheader()
            writer.writerow(row_data)

    except json.JSONDecodeError:
        print(f"ERROR: Invalid JSON response from AI:\n{ai_response}")
    except Exception as e:
        print(f"Error saving to CSV: {e}")


# --- 5. Main execution ---
if __name__ == "__main__":
    PROJECT_ID = "sentryx-474916"
    os.environ["GCLOUD_PROJECT"] = PROJECT_ID

    triage_llm = create_llm_chain()
    if triage_llm:
        script_dir = os.path.dirname(__file__)
        project_root = os.path.abspath(os.path.join(script_dir, os.pardir))
        input_dir = os.path.join(script_dir, 'triage-input')
        output_dir = os.path.join(project_root, 'visualization', 'grafana-data')

        os.makedirs(output_dir, exist_ok=True)
        output_csv_path = os.path.join(output_dir, 'triage_results.csv')

        log_files = [f for f in os.listdir(input_dir) if f.endswith('.json')]

        for log_file in log_files:
            log_file_path = os.path.join(input_dir, log_file)
            try:
                with open(log_file_path, 'r') as f:
                    log_json = json.load(f)
                    log_data_str = json.dumps(log_json, indent=2)

                print(f"\n--- Analyzing Log File: {log_file} ---")
                json_result = triage_alert_structured(log_data_str)

                print(f"\nAI JSON Response:\n{json_result}")
                save_triage_result(output_csv_path, log_json, json_result)
                print(f"✅ Result saved to: {output_csv_path}\n---------------------------------------")

            except (FileNotFoundError, json.JSONDecodeError) as e:
                print(f"Error processing {log_file}: {e}")
