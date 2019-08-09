# create terraform project-creator service account
# this service account is used for deploying all projects in the organisation

resource google_service_account project_creator {
  account_id   = "tf-project-creator"
  display_name = "Terraform Project Creator SA"
  project      = google_project.bootstrap.project_id
}

resource google_service_account_key project_creator {
  service_account_id = google_service_account.project_creator.name
}

locals {
  project_creator_sa = format(
    "serviceAccount:%s",
    google_service_account.project_creator.email,
  )

  # IAM roles to add to the Organization for project-creator service account
  # Allow project-creator service account to..
  org_iam_roles = [
    # .. read the organization info via a data source
    "roles/resourcemanager.organizationViewer",
    # .. bind a new project to a billing account
    "roles/billing.user",
  ]

  # IAM roles to add to "Terraform Managed" for project-creator service account
  # Allow project-creator service account to..
  terraform_folder_iam_roles = [
    # .. create new projects
    "roles/resourcemanager.projectCreator",
    # .. delete new projects
    "roles/resourcemanager.projectDeleter",
    # .. read GCP folders
    "roles/resourcemanager.folderViewer",
    # .. create new buckets for sub-projects
    "roles/storage.admin",
  ]

  # IAM roles to add to bootstrap project for project-creator service account
  # Allow project-creator service account to..
  bootstrap_project_iam_roles = [
    # .. query resources in the bootstrap project
    "roles/browser",
  ]
}

# Allow project-creator service account to access Terraform storage bucket
# Bucket name matches the bootstrap project name
resource google_storage_bucket_iam_member bucket_storage_objectAdmin {
  bucket = google_project.bootstrap.project_id
  role   = "roles/storage.objectAdmin"
  member = local.project_creator_sa
}

# Apply IAM roles to the organisation for the project-creator service account
resource google_organization_iam_member roles {
  org_id = data.google_organization.org.id
  count  = length(local.org_iam_roles)
  role   = local.org_iam_roles[count.index]
  member = local.project_creator_sa
}

# Apply IAM roles to the Terraform folder for the project-creator service account
resource google_folder_iam_member roles {
  folder = google_folder.terraform_managed.name
  count  = length(local.terraform_folder_iam_roles)
  role   = local.terraform_folder_iam_roles[count.index]
  member = local.project_creator_sa
}

# Apply IAM roles to the bootstrap project for the project-creator service account
resource google_project_iam_member bootstrap_roles {
  project = google_project.bootstrap.project_id
  count   = length(local.bootstrap_project_iam_roles)
  role    = local.bootstrap_project_iam_roles[count.index]
  member  = local.project_creator_sa
}
