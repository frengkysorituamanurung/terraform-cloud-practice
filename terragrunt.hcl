generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "intern-sre"

    workspaces {
      name = "learn-terraform"
    }
  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

provider "google" {
  project = "intern-infra"
  region  = "asia-southeast2"
  zone    = "asia-southeast2-a"
}
EOF
}
