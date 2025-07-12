variable "project_id" {
  type = string
}


variable "machine_type" {
  type = string
}

variable "image" {
  type = string
}

variable "size" {
  type = number
}

variable "region" {
  type = string
}

variable "network_name" {
  type = string
}

variable "zone" {
  type = string
}

variable "ssh_path_to_bastion" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "public_subnet_name" {
  type = string
}
variable "private_subnet_name" {
  type = string
}
