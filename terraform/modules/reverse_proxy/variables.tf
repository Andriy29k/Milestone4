variable "project_id" {}
variable "region" {}
variable "zone" {}
variable "network_name" {}
variable "public_subnet_name" {}

variable "machine_type" {
  type = string
}

variable "image" {
  type = string
}

variable "size" {
  type = number
}

variable "ssh_path_over_bastion" {
  type = string
}

variable "ssh_user" {
  type = string
}
