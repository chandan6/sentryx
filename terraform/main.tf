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

# This resource is for testing the "shift-left" policy
resource "google_storage_bucket" "test_bucket" {
  name     = "sentryx-test-bucket-for-iac-scan"
  location = "US"
}