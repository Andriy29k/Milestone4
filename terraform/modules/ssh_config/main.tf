locals {
  ssh_config_content = <<-EOT
# Bastion
Host bastion
    HostName ${var.bastion_public_ip}
    User ${var.ssh_user}
    IdentityFile ${var.ssh_path_to_bastion_private}
    ForwardAgent yes
    StrictHostKeyChecking no

# Machines
${join("\n", [
  for machine in var.machines : format(
    "Host %s\n HostName %s\n User %s\n IdentityFile %s\n ProxyJump bastion\n StrictHostKeyChecking no",
    machine,
    var.machine_private_ips[machine],
    var.ssh_user,
    var.ssh_path_over_bastion_private
  )
])}
EOT
}

resource "local_file" "ssh_config" {
  content  = local.ssh_config_content
  filename = pathexpand("/home/andriy29k/.ssh/config")
}
