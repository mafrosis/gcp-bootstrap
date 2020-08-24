# create terraform resources to control the bootstrapped state backend bucket

resource random_id key_suffix {
  byte_length = 2
}

resource google_kms_key_ring terraform_state {
  name     = "terraform-keyring"
  project  = google_project.bootstrap.project_id
  location = var.region
}

resource google_kms_crypto_key terraform_state {
  name            = "terraform-state-key-${random_id.key_suffix.hex}"
  key_ring        = google_kms_key_ring.terraform_state.self_link
  rotation_period = "15552000s" # 6 months
}

# Allow Cloud Storage to use encrypt/decrypt keys on this project
resource google_project_iam_member terraform_state_encrypt_decrypt {
  project = google_project.bootstrap.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${google_project.bootstrap.number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource google_storage_bucket terraform_state {
  name     = google_project.bootstrap.project_id
  project  = google_project.bootstrap.project_id
  location = var.region

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.terraform_state.self_link
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    google_project_iam_member.terraform_state_encrypt_decrypt
  ]
}
