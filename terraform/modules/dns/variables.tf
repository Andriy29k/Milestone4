variable "dns_name" {
  type = string
  description = "The name of the DNS zone"
}

variable "dns" {
  type = string
  description = "The DNS name for the zone, e.g., 'example.com.'"
  
}

variable "external_ip" {
  description = "The IP address for the reverse proxy/load balancer"
  type        = string
}
