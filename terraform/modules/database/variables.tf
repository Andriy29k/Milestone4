variable "zone" {
  description = "The zone in which resources will be created"
  type        = string
}

variable "db_machine_type" {
  description = "The type of machine to create"
  type        = string
}

variable "image" {
  description = "The image to use for the boot disk"
  type        = string
}

variable "size" {
  description = "The size of the boot disk in GB"
  type        = number
}

variable "ssh_path_over_bastion" {
  type = string
}

variable "ssh_user" {
  description = "The SSH user for the instance"
  type        = string
}

variable "public_subnet_name" {}
variable "private_subnet_name" {}
