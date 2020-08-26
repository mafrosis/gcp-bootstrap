# project which hosts Google oAuth application used for SSH
# https://smallstep.com/blog/diy-single-sign-on-for-ssh/
#
module ssh_via_oauth {
  source = "../modules/gcp-project"

  billing_account      = var.billing_account
  folder_id            = var.project_folder_id
  project_name         = "ssh-via-oauth"
  bootstrap_project_id = var.bootstrap_project_id

  create_vpc = false
}

output project_id {
  value = module.ssh_via_oauth.project_id
}

output service_account {
  value = module.ssh_via_oauth.service_account
}

output service_account_key {
  value     = module.ssh_via_oauth.service_account_key
  sensitive = true
}

output tf_state_storage_bucket {
  value = module.ssh_via_oauth.tf_state_storage_bucket
}

output project_keyring {
  value = module.ssh_via_oauth.project_keyring
}
