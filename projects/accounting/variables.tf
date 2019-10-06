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
