terraform {
  required_version = "1.15.8"
  cloud {

    organization = "soybagel"

    workspaces {
      name = "local"
    }
  }
}
