# create folder hierarchy for all projects in the organisation

resource google_folder terraform_managed {
  display_name = "Terraform Managed"
  parent       = data.google_organization.org.name
}

output terraform_managed_folder_id {
  value = google_folder.terraform_managed.id
}
