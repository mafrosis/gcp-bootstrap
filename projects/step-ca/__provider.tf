terraform {
  required_version = ">= 0.12"

  backend "gcs" {
    prefix = "projects/step-ca"
  }
}

provider google {
  version = "~> 3.28.0"
}

provider google-beta {
  version = "~> 3.28.0"
}

provider aws {
  version = "~> 2.70.0"
}

provider random {
  version = "~> 2.1"
}
