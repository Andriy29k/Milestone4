output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "network_name" {
  value = google_compute_network.vpc.name
}

output "public_subnet_name" {
  value = google_compute_subnetwork.public_subnet.name
}

output "private_subnet_name" {
  value = google_compute_subnetwork.private_subnet.name
}

output "public_subnet_ip_range" {
  value = google_compute_subnetwork.public_subnet.ip_cidr_range
}

output "private_subnet_ip_range" {
  value = google_compute_subnetwork.private_subnet.ip_cidr_range
}
