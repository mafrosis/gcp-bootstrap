variable region {
  description = "Default GCP region"
  type        = string
  default     = "australia-southeast1"
}

variable domain {
  description = "Domain name attached to GCP organisation"
  type        = string
  default     = "gcp.mafro.dev"
}

variable billing_account {
  description = "GCP billing account ID used for this organisation"
  type        = string
}

variable bootstrap_project_id {
  description = "GCP Project used to bootstrap the organisation for automation"
  type        = string
}

variable terraform_root_service_account_name {
  description = "Name of the Terraform root service account (which has organization privileges)"
  type        = string
  default     = "terraform-root"
}

variable project_services {
  description = "The GCP APIs to be enabled on this project"
  type        = list(string)
  default     = [
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
  ]
}

variable root_service_account_iam_roles {
  description = "Organization IAM roles assigned to the root Terraform service account"
  type        = list(string)
  default     = [
    "roles/billing.user",
    "roles/editor",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.organizationAdmin",
    "roles/storage.admin",
  ]
}
