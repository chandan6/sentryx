terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "sentryx-474916"
  region  = "us-central1"
}

resource "google_storage_bucket" "test_bucket_iac" {
  name                          = "sentryx-iac-test-bucket-12345" # Make sure this is globally unique
  location                      = "US"
  uniform_bucket_level_access = true  # <-- This is the line you are adding
  
}