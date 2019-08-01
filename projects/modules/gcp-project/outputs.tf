output project_id {
  value = google_project.project.project_id
}

output service_account {
  value = google_service_account.project.email
}

output service_account_key {
  value     = google_service_account_key.project.private_key
  sensitive = true
}

output tf_state_storage_bucket {
  value = google_storage_bucket.terraform_state.name
}
