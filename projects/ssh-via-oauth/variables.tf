variable region {
  description = "Default GCP region"
  type        = string
  default     = "australia-southeast1"
}

variable billing_account {
  description = "GCP billing account ID used for this organisation"
  type        = string
}

variable project_folder_id {
  description = "GCP folder hosting this project"
  type        = string
}

variable bootstrap_project_id {
  description = "GCP Project ID where the terraform state file is hosted"
  type        = string
}
