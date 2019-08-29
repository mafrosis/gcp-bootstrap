# create a general purpose KMS keyring for this project
#
resource google_kms_key_ring project {
  name     = format("%s-keyring", var.project_name)
  project  = google_project.project.project_id
  location = var.region

  depends_on = [
    google_project_service.apis
  ]
}

output project_keyring {
  value = google_kms_key_ring.project.name
}
