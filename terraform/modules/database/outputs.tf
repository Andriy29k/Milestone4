output "database_internal_ip" {
  value = google_compute_instance.database.network_interface[0].network_ip
}