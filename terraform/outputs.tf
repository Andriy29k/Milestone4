output "bastion_external_ip" {
  value = module.bastion.bastion_external_ip
}

output "bastion_internal_ip" {
  value = module.bastion.bastion_internal_ip
}

output "frontend_internal_ip" {
  value = module.compute.frontend_internal_ip
}

output "backend_internal_ip" {
  value = module.compute.backend_internal_ip
}

output "monitoring_internal_ip" {
  value = module.compute.monitoring_internal_ip
}

output "control_plane_internal_ip" {
  value = module.compute.control_plane_internal_ip
}

output "database_internal_ip" {
  value = module.database.database_internal_ip
}

output "reverse_proxy_internal_ip" {
  value = module.reverse_proxy.reverse_proxy_internal_ip
}

output "reverse_proxy_external_ip" {
  value = module.reverse_proxy.reverse_proxy_external_ip
}

output "all_internal_ips" {
  value = module.compute.all_internal_ips
}

output "ssh_user" {
  value = var.ssh_user
}

output "ssh_path_to_bastion" {
  value = var.ssh_path_to_bastion
}

output "ssh_path_over_bastion" {
  value = var.ssh_path_over_bastion
}

output "ssh_path_to_bastion_private" {
  value = var.ssh_path_to_bastion_private
}

output "ssh_path_over_bastion_private" {
  value = var.ssh_path_over_bastion_private
}

output "debug_machines" {
  value = keys(module.compute.all_internal_ips)
}

output "debug_machine_ips" {
  value = module.compute.all_internal_ips
}

