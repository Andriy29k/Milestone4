variable "project_id" {}
variable "region" {}
variable "zone" {}
variable "network_name" {}
variable "public_subnet_name" {}

variable "machine_type" {
  default = "e2-small"
}

variable "image" {
  default = "debian-cloud/debian-12"
}

variable "size" {
  type = number
}

variable "ssh_path_over_bastion" {
  type    = string
}

variable "ssh_user" {
  default = "andrii"
}