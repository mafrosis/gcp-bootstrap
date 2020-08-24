# create folder hierarchy for all projects in the organisation

resource google_folder managed_projects_folder {
  display_name = "Projects"
  parent       = data.google_organization.org.name
}

output managed_projects_folder_id {
  value = google_folder.managed_projects_folder.id
}
