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

variable bootstrap_project_id {
  description = "GCP Project used to bootstrap the organisation for automation"
  type        = string
}
