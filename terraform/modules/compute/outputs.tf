output "frontend_internal_ip" {
  description = "Internal IP of the frontend instance"
  value       = google_compute_instance.service["frontend"].network_interface[0].network_ip
}

output "backend_internal_ip" {
  description = "Internal IP of the backend instance"
  value       = google_compute_instance.service["backend"].network_interface[0].network_ip
}

output "monitoring_internal_ip" {
  description = "Internal IP of the monitoring instance"
  value       = google_compute_instance.service["monitoring"].network_interface[0].network_ip
}

output "control_plane_internal_ip" {
  description = "Internal IP of the control-plane instance"
  value       = google_compute_instance.service["control-plane"].network_interface[0].network_ip
}

output "all_internal_ips" {
  description = "Map of internal IPs for all compute services"
  value = {
    for svc, instance in google_compute_instance.service :
    svc => instance.network_interface[0].network_ip
  }
}
