output "reverse_proxy_internal_ip" {
  value = google_compute_instance.reverse_proxy.network_interface[0].network_ip
}

output "reverse_proxy_external_ip" {
  value = google_compute_instance.reverse_proxy.network_interface[0].access_config[0].nat_ip
}