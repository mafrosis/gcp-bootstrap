data "google_organization" "org" {
  domain = "${var.domain}"
}

resource "google_folder" "terraform_managed" {
  display_name = "Terraform Managed"
  parent       = "${data.google_organization.org.name}"
}
