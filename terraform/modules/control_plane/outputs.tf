output "control_plane_internal_ip" {
  value = google_compute_instance.control_plane.network_interface[0].network_ip
}

output "control_plane_external_ip" {
  value = google_compute_instance.control_plane.network_interface[0].access_config[0].nat_ip
}