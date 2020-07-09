# create GCS bucket for project's terraform state storage
#
locals {
  cloud_storage_sa = format(
    "serviceAccount:service-%s@gs-project-accounts.iam.gserviceaccount.com",
    google_project.project.number,
  )
}

resource random_id key_suffix {
  byte_length = 2
}

resource google_kms_key_ring terraform_state {
  name     = "terraform-keyring"
  project  = google_project.project.project_id
  location = var.region

  depends_on = [
    google_project_service.apis
  ]
}

resource google_kms_crypto_key terraform_state {
  name            = format("terraform-state-key-%s", random_id.key_suffix.hex)
  key_ring        = google_kms_key_ring.terraform_state.self_link
  rotation_period = "15552000s" # 6 months
}

# Allow Cloud Storage to use the KMS encryption keys
resource google_kms_crypto_key_iam_member terraform_state_encrypt_decrypt {
  crypto_key_id = google_kms_crypto_key.terraform_state.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = local.cloud_storage_sa

  depends_on = [
    google_project_service.apis
  ]
}

resource google_storage_bucket terraform_state {
  name     = format("%s-terraform-state", google_project.project.project_id)
  project  = google_project.project.project_id
  location = var.region

  # delete the bucket even if it contains files
  force_destroy = true

  versioning {
    enabled = false
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.terraform_state.self_link
  }

  depends_on = [
    google_kms_crypto_key_iam_member.terraform_state_encrypt_decrypt
  ]
}
