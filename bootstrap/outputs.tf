output tf_project_creator {
  value = local.project_creator_sa
}

output tf_project_creator_key {
  value     = google_service_account_key.project_creator.private_key
  sensitive = true
}

output dns_managed_zone_name {
  value = google_dns_managed_zone.root.name
}
