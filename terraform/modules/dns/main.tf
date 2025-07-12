resource "google_dns_managed_zone" "main" {
  name        = "class-schedule-zone"
  dns_name    = var.dns_name
  description = "DNS zone for class-schedule app"
  visibility  = "public"
}

resource "google_dns_record_set" "a_record" {
  name         = var.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.main.name
  rrdatas      = [var.external_ip]
}
