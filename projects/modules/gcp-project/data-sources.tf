data google_folder project_folder {
  folder = var.folder_id
}

data google_project bootstrap_project {
  project_id = var.bootstrap_project_id
}
