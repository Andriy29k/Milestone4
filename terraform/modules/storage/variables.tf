variable "project_id" {
    description = "The ID of the GCP project where resources will be created"
    type        = string
}

variable "bucket_name" {
    description = "The name of the GCS bucket to create"
    type        = string
  
}

variable "storage_class" {
    description = "The storage class for the GCS bucket"
    type        = string
  
}

variable "location" {
    description = "The location for the GCS bucket"
    type        = string
  
}