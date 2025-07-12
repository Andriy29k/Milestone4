variable "dns_name" {
  type = string
  description = "The name of the DNS zone"
}

variable "external_ip" {
  description = "The IP address for the reverse proxy/load balancer"
  type        = string
}
