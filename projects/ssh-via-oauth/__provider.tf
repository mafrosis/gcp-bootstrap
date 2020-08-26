terraform {
  required_version = "~> 0.12.28"
  required_providers {
    google      = ">= 2.7, <4.0"
    google-beta = ">= 2.7, <4.0"
  }

  backend "gcs" {
    prefix = "projects/google-oauth"
  }
}

provider google {
  version = "~> 3.31.0"
}

provider google-beta {
  version = "~> 3.31.0"
}

provider random {
  version = "~> 2.1"
}
