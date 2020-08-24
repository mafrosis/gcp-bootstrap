# create new project
#
locals {
  # APIs to turn on in workload projects
  # Can be extended via var.project_apis
  base_apis = [
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "networkmanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
  ]

  # IAM roles to add to bootstrap project for new project's service account
  all_apis = distinct(concat(local.base_apis, var.project_apis))

  # On the bootstrap project, allow workload project's service account to  ..
  bootstrap_project_iam_roles = [
    # .. read the root DNS zone
    "roles/dns.reader",
  ]
}

resource random_id project_suffix {
  byte_length = 3
}

resource google_project project {
  project_id      = format("%s-%s", var.project_name, random_id.project_suffix.hex)
  name            = var.project_name
  folder_id       = var.folder_id
  billing_account = var.billing_account

  auto_create_network = false
}

# Activate required service APIs on the project
resource google_project_service apis {
  count   = length(local.all_apis)
  project = google_project.project.project_id
  service = local.all_apis[count.index]

  disable_on_destroy = false
}

# Apply IAM roles to the bootstrap project for new project's service account
resource google_project_iam_member bootstrap_roles {
  project = data.google_project.bootstrap_project.project_id
  count   = length(local.bootstrap_project_iam_roles)
  role    = local.bootstrap_project_iam_roles[count.index]
  member  = local.project_sa
}
