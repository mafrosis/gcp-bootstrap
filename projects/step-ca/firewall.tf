# Ingress firewall rules specific to Step CA project
#

# Open port 443 from my home IP
resource google_compute_firewall gce_https {
  project = module.step_ca.project_id
  network = module.step_ca.network
  name    = "allow-ingress-443"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["210.50.205.29/32"]
}

data aws_ip_ranges ireland_ec2 {
  regions  = ["eu-west-1"]
  services = ["ec2"]
}

resource google_compute_firewall ec2_ireland_https {
  project = module.step_ca.project_id
  network = module.step_ca.network
  name    = "allow-https-ingress-from-ec2-ireland"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = data.aws_ip_ranges.ireland_ec2.cidr_blocks
}
