resource google_project bootstrap {
  project_id      = var.bootstrap_project_id
  name            = var.bootstrap_project_id
  org_id          = data.google_organization.org.id
  billing_account = var.billing_account

  auto_create_network = false

  lifecycle {
    prevent_destroy = true
  }
}

resource google_project_service apis {
  count   = length(var.project_services)
  project = google_project.bootstrap.project_id
  service = var.project_services[count.index]

  disable_on_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

resource google_service_account terraform {
  account_id   = var.terraform_root_service_account_name
  display_name = "Terraform"
  project      = google_project.bootstrap.project_id

  depends_on = [
    google_project_service.apis
  ]

  lifecycle {
    prevent_destroy = true
  }
}

resource google_organization_iam_member service_account {
  count  = length(var.root_service_account_iam_roles)
  org_id = data.google_organization.org.id
  role   = var.root_service_account_iam_roles[count.index]
  member = "serviceAccount:${google_service_account.terraform.email}"

  lifecycle {
    prevent_destroy = true
  }
}
