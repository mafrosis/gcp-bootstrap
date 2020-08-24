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

variable folder_id {
  description = "GCP folder ID hosting this project"
  type        = string
}

variable project_name {
  description = "GCP Project name (random suffix is appended for the unique GCP project ID)"
  type        = string
}

variable project_apis {
  description = "Extra GCP APIs to be enabled on this project"
  type        = list(string)
  default     = []
}

variable extra_project_iam_roles {
  description = "Extra IAM roles enabled on this project for the project's service account"
  type        = list(string)
  default     = []
}

variable dns_subdomain {
  description = "Subdomain for the zone under which all DNS for this project can be created"
  type        = string
  default     = null
}

variable create_vpc {
  description = "Flag indicating whether to delete the default VPC from the new project (default: false)"
  type        = bool
  default     = false
}

variable subnet_ip_ranges {
  description = "Specify the subnet ranges for the VPC"
  type = list(object({
    subnet = string
    region = string
  }))
  default = []
}
