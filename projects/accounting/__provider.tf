terraform {
  required_version = ">= 0.12"

  backend "gcs" {
    prefix = "projects/accounting"
  }
}

provider google {
  version = "~> 2.13.0"
}

provider google-beta {
  version = "~> 2.13.0"
}

provider random {
  version = "~> 2.1"
}
