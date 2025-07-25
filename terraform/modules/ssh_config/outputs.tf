output "ssh_config_summary" {
  value = concat(
    [
      {
        machine = "bastion"
        ip      = var.bastion_public_ip
        user    = var.ssh_user
        key     = var.ssh_path_to_bastion_private
      }
    ],
    [
      for m in var.machines : {
        machine = m
        ip      = var.machine_private_ips[m]
        user    = var.ssh_user
        key     = var.ssh_path_over_bastion_private
      }
    ],
    [
      {
        machine = "control_plane"
        ip      = var.control_plane_ip
        user    = var.ssh_user
        key     = var.ssh_path_over_bastion_private
      },
      {
        machine = "database"
        ip      = var.database_ip
        user    = var.ssh_user
        key     = var.ssh_path_over_bastion_private
      }
    ]
  )
}
