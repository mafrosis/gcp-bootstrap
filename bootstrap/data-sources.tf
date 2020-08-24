data google_project bootstrap_project {
  project_id = var.bootstrap_project_id
}

data google_organization org {
  organization = data.google_project.bootstrap_project.org_id
}
