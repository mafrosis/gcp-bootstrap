terraform {
  required_version = ">= 0.12"

  backend "gcs" {}
}

provider google {
  version = "~> 2.20.2"
}

provider google-beta {
  version = "~> 2.20.2"
}

provider random {
  version = "~> 2.1"
}
