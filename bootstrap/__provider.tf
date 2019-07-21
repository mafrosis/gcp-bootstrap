terraform {
  required_version = ">= 0.12"

  backend "gcs" {
    prefix = "bootstrap"
  }
}

provider google {
  version = "~> 2.11.0"
}

provider google-beta {
  version = "~> 2.11.0"
}

provider random {
  version = "~> 2.1"
}
