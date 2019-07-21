# create a terraform service account
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
}

# Allow service account to access Terraform storage bucket
# Bucket name matches the bootstrap project name
resource google_storage_bucket_iam_member bucket_storage_objectAdmin {
  bucket = google_project.bootstrap.project_id
  role   = "roles/storage.objectAdmin"
  member = local.project_creator_sa
}

# Role organization.viewer is required convert the domain into an organization number
resource google_organization_iam_member organization_resourcemanager_organizationViewer {
  org_id = data.google_organization.org.id
  role   = "roles/resourcemanager.organizationViewer"
  member = local.project_creator_sa
}

# Role billing.user is required to bind a new project to a billing account
resource google_organization_iam_member organization_billing_user {
  org_id = data.google_organization.org.id
  role   = "roles/billing.user"
  member = local.project_creator_sa
}

# Role roles/resourcemanager.projectCreator is necessary to .. create new projects
resource google_folder_iam_member folder_resourcemanager_projectCreator {
  folder = google_folder.terraform_managed.name
  role   = "roles/resourcemanager.projectCreator"
  member = local.project_creator_sa
}

# Role roles/resourcemanager.projectDeleter is necessary to .. delete new projects
resource google_folder_iam_member resourcemanager_projectDeleter {
  folder = google_folder.terraform_managed.name
  role   = "roles/resourcemanager.projectDeleter"
  member = local.project_creator_sa
}

# Role resourcemanager.folderViewer allows terraform to read GCP folders
resource google_folder_iam_member folder_resourcemanager_folderViewer {
  folder = google_folder.terraform_managed.name
  role   = "roles/resourcemanager.folderViewer"
  member = local.project_creator_sa
}

# Role storage.admin enables terraform to create new buckets for sub-projects
resource google_folder_iam_member folder_storage_admin {
  folder = google_folder.terraform_managed.name
  role   = "roles/storage.admin"
  member = local.project_creator_sa
}
