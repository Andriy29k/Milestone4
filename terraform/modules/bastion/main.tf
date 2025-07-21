# Bastion
resource "google_compute_instance" "bastion" {
  name         = "bastion"
  project      = var.project_id
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.size
    }
  }


  metadata = {
    ssh-keys = "${var.ssh_user}:${chomp(file(var.ssh_path_to_bastion))}"
  }

  network_interface {
    subnetwork = var.public_subnet_name
    access_config {}
  }

  tags = ["bastion"]
}
