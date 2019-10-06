# project creation for accounting firebase app
#
module accounting_project {
  source = "../modules/gcp-project"

  billing_account      = var.billing_account
  folder_id            = var.project_folder_id
  project_name         = "accounting"
  dns_subdomain        = "accounting"
  bootstrap_project_id = var.bootstrap_project_id

  project_apis = [
    "cloudbuild.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "firebasehosting.googleapis.com",
    "firestore.googleapis.com",
    "run.googleapis.com",
    "sourcerepo.googleapis.com",
  ]

  # Allow project's service account to ..
  extra_project_iam_roles = [
    # .. create & cancel Cloud Build jobs
    "roles/cloudbuild.builds.editor",
    # .. create/update all Firebase resources
    "roles/firebase.developAdmin",
    # .. have full control over Cloud Run resources
    "roles/run.admin",
    # .. admin access to repositories
    "roles/source.admin",
  ]
}

output project_id {
  value = module.accounting_project.project_id
}

output service_account {
  value = module.accounting_project.service_account
}

output service_account_key {
  value     = module.accounting_project.service_account_key
  sensitive = true
}
