# create a DNS subzone for this project
#
locals {
  dns_subdomain = var.dns_subdomain == null ? var.project_name : var.dns_subdomain
}

# Lookup the root zone
data google_dns_managed_zone root {
  project = var.bootstrap_project_id
  name    = "root"
}

# Create the project's sub-zone
resource google_dns_managed_zone project {
  project     = google_project.project.project_id
  name        = local.dns_subdomain
  dns_name    = format("%s.%s", local.dns_subdomain, data.google_dns_managed_zone.root.dns_name)
  description = format("%s project DNS zone", var.project_name)
  visibility  = "public"

  depends_on = [
    google_project_service.base_apis
  ]
}

# Add nameservers for sub-zone to root zone on bootstrap project
resource google_dns_record_set nameservers {
  name         = format("%s.%s", local.dns_subdomain, data.google_dns_managed_zone.root.dns_name)
  project      = data.google_project.bootstrap_project.project_id
  managed_zone = data.google_dns_managed_zone.root.name
  type         = "NS"
  ttl          = 300
  rrdatas      = google_dns_managed_zone.project.name_servers
}
