output "bucket_name" {
  value = google_storage_bucket.artifacts.name
}

output "bucket_url" {
  value = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.artifacts.name}"
}

output "bucket_self_link" {
  description = "The self link of the GCS bucket"
  value       = google_storage_bucket.artifacts.self_link
}