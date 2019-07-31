# create DNS root zone for the GCP organisation

resource google_dns_managed_zone root {
  project     = google_project.bootstrap.project_id
  name        = "root"
  dns_name    = "${var.domain}."
  description = "Root DNS zone"
  visibility  = "public"
}
