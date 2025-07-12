resource "google_storage_bucket" "artifacts" {
  name          = var.bucket_name
  location      = var.location
  storage_class = var.storage_class

  versioning {
    enabled = false
  }

  uniform_bucket_level_access = true

  labels = {
    environment = "prod"
    type        = "artifacts"
  }
}