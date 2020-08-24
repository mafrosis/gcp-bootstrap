locals {
  create_vpc = var.create_vpc ? 1 : 0
}

resource google_compute_network network {
  count = local.create_vpc

  name    = format("vpc-%s", random_id.project_suffix.hex)
  project = google_project.project.project_id

  auto_create_subnetworks = false
}

resource google_compute_subnetwork subnet {
  count = length(var.subnet_ip_ranges)

  name          = format("subnet-%s-%s", random_id.project_suffix.hex, count.index)
  project       = google_project.project.project_id
  network       = google_compute_network.network[0].self_link
  region        = var.subnet_ip_ranges[count.index].region
  ip_cidr_range = var.subnet_ip_ranges[count.index].subnet

  private_ip_google_access = true
}

# Enable GCE VM healthchecks as standard across all projects
resource google_compute_firewall gce_healthcheck {
  count = local.create_vpc

  project = google_project.project.project_id
  network = google_compute_network.network[0].self_link
  name    = "allow-gce-healthcheck"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}
