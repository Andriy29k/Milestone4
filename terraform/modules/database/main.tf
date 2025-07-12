resource "google_compute_instance" "database" {
  name         = "database"
  machine_type = var.db_machine_type
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
  }

  tags = ["database"]
}
