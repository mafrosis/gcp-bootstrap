# create project service account
#
locals {
  project_sa = format(
    "serviceAccount:%s",
    google_service_account.project.email,
  )

  # Allow project's service account to ..
  project_iam_roles = [
    # .. administer the project's DNS zone
    "roles/dns.admin",
    # .. create additional service accounts and keys
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    # .. start GCP services as other service accounts in this project
    "roles/iam.serviceAccountUser",
    # .. add iam roles
    "roles/resourcemanager.projectIamAdmin",
    # .. have full access to cloud storage for the project
    "roles/storage.admin",
    # .. have full access to administer KMS keyrings/keys for the project
    "roles/cloudkms.admin",
    # .. ability to access encrypted secrets
    "roles/secretmanager.secretAccessor",
  ]

  all_iam_roles = distinct(concat(local.project_iam_roles, var.extra_project_iam_roles))
}

# Create service account for this project
resource google_service_account project {
  account_id   = format("tf-%s", var.project_name)
  display_name = format("Terraform Project %s SA", title(var.project_name))
  project      = google_project.project.project_id
}

resource google_service_account_key project {
  service_account_id = google_service_account.project.name
}

# Enable project's service account to access project's Terraform storage bucket
# Bucket name is based on the project_id
resource google_storage_bucket_iam_member bucket_storage_objectAdmin {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectAdmin"
  member = local.project_sa
}

# Apply IAM roles to the project for project's service account
resource google_project_iam_member roles {
  project = google_project.project.project_id
  count   = length(local.all_iam_roles)
  role    = local.all_iam_roles[count.index]
  member  = local.project_sa
}
