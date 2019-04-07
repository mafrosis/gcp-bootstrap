variable "region" {
  default = "australia-southeast1"
}

variable "domain" {}

variable "bootstrap_project_id" {
  description = "GCP Project used to bootstrap the organisation for automation"
}
