output tf_project_creator {
  value = local.project_creator_sa
}

output tf_project_creator_key {
  value = google_service_account_key.project_creator.private_key
}
