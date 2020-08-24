# project creation for Smallstep CA in Cloud Run
#
module step_ca {
  source = "../modules/gcp-project"

  billing_account      = var.billing_account
  folder_id            = var.project_folder_id
  project_name         = "step-ca"
  dns_subdomain        = "ca"
  bootstrap_project_id = var.bootstrap_project_id

  create_vpc = true
  subnet_ip_ranges = [{
    subnet = "10.1.1.0/24"
    region = "australia-southeast1"
  }]

  project_apis = [
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "containerregistry.googleapis.com",
    "run.googleapis.com",
    "sourcerepo.googleapis.com",
    "vpcaccess.googleapis.com",
  ]

  # Allow project's service account to ..
  extra_project_iam_roles = [
    # .. create & cancel Cloud Build jobs
    "roles/cloudbuild.builds.editor",
    # .. have full control over Cloud Run resources
    "roles/run.admin",
    # .. admin access to repositories
    "roles/source.admin",
    # .. create and manage VM instances
    "roles/compute.instanceAdmin.v1",
    "roles/compute.networkAdmin",
    # .. create VPC connectors
    "roles/vpcaccess.admin",
  ]
}

output project_id {
  value = module.step_ca.project_id
}

output service_account {
  value = module.step_ca.service_account
}

output service_account_key {
  value     = module.step_ca.service_account_key
  sensitive = true
}

output tf_state_storage_bucket {
  value = module.step_ca.tf_state_storage_bucket
}

output project_keyring {
  value = module.step_ca.project_keyring
}
