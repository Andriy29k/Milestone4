locals {
  services = {
    frontend   = "frontend"
    backend    = "backend"
    monitoring = "monitoring"
    control-plane = "control_plane"
  }
}

#Backend & Frontend & Monitoring Compute Instances
resource "google_compute_instance" "service" {
  for_each     = local.services
  name         = each.key
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.size
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${chomp(file(var.ssh_path_over_bastion))}"
  }

  network_interface {
    subnetwork = var.private_subnet_name
    # No external IP
  }

  tags = [each.value]
}
