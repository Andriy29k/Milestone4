variable "google_credentials_file" {
  type        = string
  description = "Path to the Google Cloud service account credentials JSON file."
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "network_name" {
  type    = string
  default = "project-vpc"
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "db_machine_type" {
  type = string
}

variable "image" {
  type = string
}

variable "size" {
  type = number
}

variable "ssh_user" {
  type = string
}

variable "ssh_path_to_bastion" {
  type = string
}

variable "ssh_path_over_bastion" {
  type = string
}

variable "machines" {
  type    = list(string)
  default = ["frontend", "backend", "monitoring"]
}

variable "ssh_path_to_bastion_private" {
  type = string
}

variable "ssh_path_over_bastion_private" {
  type = string
}