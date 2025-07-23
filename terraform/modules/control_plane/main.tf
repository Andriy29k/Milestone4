resource "google_compute_instance" "reverse_proxy" {
  name         = "control-plane"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.size
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_path_over_bastion)}"
  }

  network_interface {
    subnetwork = var.public_subnet_name
    access_config {}
  }

  tags = ["control-plane"]
}
