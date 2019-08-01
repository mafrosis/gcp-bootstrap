# create project service account
#
locals {
  project_sa = format(
    "serviceAccount:%s",
    google_service_account.project.email,
  )

  # Allow project's service account to ..
  project_iam_roles = [
    # .. create additional service accounts and keys
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    # .. add iam roles
    "roles/resourcemanager.projectIamAdmin",
    # .. have full access to cloud storage
    "roles/storage.admin",
  ]
}

# Create service account for this project
resource google_service_account project {
  account_id   = "tf-${var.project_name}"
  display_name = "Terraform Project ${title(var.project_name)} SA"
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
  count   = length(local.project_iam_roles)
  role    = local.project_iam_roles[count.index]
  member  = local.project_sa
}
