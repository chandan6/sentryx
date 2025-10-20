resource "google_storage_bucket" "test_bucket_iac" {
  name                          = "sentryx-iac-test-bucket-12345"
  location                      = "US"
  uniform_bucket_level_access = true  # <-- This is the FIX
}