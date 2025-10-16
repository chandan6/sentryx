import json
import os
from langchain_community.llms import LlamaCpp
from langchain_core.prompts import PromptTemplate

def create_llm_chain(model_path: str):
    """
    Loads a local GGUF model using LlamaCpp and creates a LangChain chain.
    """
    print(f"Loading GGUF model from: {model_path}...")
    try:
        # LlamaCpp is used to load GGUF format models
        llm = LlamaCpp(
            model_path=model_path,
            # FIX 1: Explicitly set to 0 for CPU-only since you installed that version.
            n_gpu_layers=0,
            n_batch=512,
            n_ctx=4096,
            verbose=False, # Set to True for detailed debugging
        )
    except Exception as e:
        print(f"Error loading model: {e}")
        return None

    # The prompt template remains the same
    prompt_template = """
    You are an expert cybersecurity analyst. Your task is to analyze a security log and classify its threat level.
    The log data is provided below in JSON format.
    
    Log Data:
    {log_data}
    
    Based on the log data, classify the threat level. Respond with only ONE of the following words: CRITICAL, HIGH, MEDIUM, or LOW.
    
    Classification:"""
    
    prompt = PromptTemplate(template=prompt_template, input_variables=["log_data"])
    
    # Use LangChain Expression Language (LCEL) to create the chain
    chain = prompt | llm
    print("Model and chain created successfully.")
    return chain

# --- Main execution block ---
if __name__ == "__main__":
    # FIX 2: Create a robust, absolute path to the model file. This is more reliable.
    script_dir = os.path.dirname(__file__) # Gets the directory of the script (ai-triage)
    project_root = os.path.abspath(os.path.join(script_dir, os.pardir)) # Goes up one level to sentryx/
    model_filename = "Phi-3-mini-4k-instruct-q4.gguf"
    gguf_model_path = os.path.join(project_root, model_filename)

    triage_chain = create_llm_chain(gguf_model_path)
    
    if triage_chain:
        log_file_path = os.path.join(script_dir, 'triage-input', 'sample_falco_log.json')

        try:
            with open(log_file_path, 'r') as f:
                log_json = json.load(f)
                log_data_str = json.dumps(log_json, indent=2)
            
            print("\n--- Analyzing Log with Phi-3 Mini (GGUF) ---")
            result = triage_chain.invoke({"log_data": log_data_str})
            
            print(f"\nDecision: {result.strip()}")
            print("---------------------------------------")

        except FileNotFoundError:
            print(f"Error: Log file not found at {log_file_path}")