# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "sre-kyy"

    workspaces {
      name = "learn-terraform-migration"
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
  project     = "intern-infra"
  region      = "asia-southeast2"
  zone        = "asia-southeast2-a"
  credentials = file("tf-key.json")
}
