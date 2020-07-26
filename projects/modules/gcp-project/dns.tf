# create a DNS subzone for this project
#
locals {
  create_zone   = var.dns_subdomain == null ? 0 : 1
  dns_subdomain = var.dns_subdomain == null ? var.project_name : var.dns_subdomain
}

# Lookup the root zone
data google_dns_managed_zone root {
  project = var.bootstrap_project_id
  name    = "root"
}

# Create the project's sub-zone
resource google_dns_managed_zone project {
  count = local.create_zone

  project     = google_project.project.project_id
  name        = local.dns_subdomain
  dns_name    = format("%s.%s", local.dns_subdomain, data.google_dns_managed_zone.root.dns_name)
  description = format("%s project DNS zone", var.project_name)
  visibility  = "public"

  depends_on = [
    google_project_service.apis
  ]
}

# Add nameservers for sub-zone to root zone on bootstrap project
resource google_dns_record_set nameservers {
  count = local.create_zone

  name         = format("%s.%s", local.dns_subdomain, data.google_dns_managed_zone.root.dns_name)
  project      = data.google_project.bootstrap_project.project_id
  managed_zone = data.google_dns_managed_zone.root.name
  type         = "NS"
  ttl          = 300
  rrdatas      = google_dns_managed_zone.project[0].name_servers
}
