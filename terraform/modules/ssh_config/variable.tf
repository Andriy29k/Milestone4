variable "bastion_public_ip" {
  type = string
}

variable "control_plane_ip" {
  type = string
}

variable "database_ip" {
  type = string
}


variable "machines" {
  type = list(string)
}

variable "machine_private_ips" {
  type = map(string)
}

variable "ssh_user" {
  type = string
}

variable "ssh_path_to_bastion_private" {
  type = string
}

variable "ssh_path_over_bastion_private" {
  type = string
}
