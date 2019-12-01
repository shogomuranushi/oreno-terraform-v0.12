terraform {
  backend "gcs" {
    bucket  = "tf-state"
    prefix  = "node-pools"
  }
}

provider "google-beta" {
  project = local.common.project
}

provider "google" {
  project = local.common.project
}

variable "common" {
  type = map(map(string))
  default = {
    dev = {
      project = "gcp-project-dev"
      region  = "us-central1"
      zone    = "us-central1-a"
    }
    stg = {
      project = "gcp-project-stg"
      region  = "us-central1"
      zone    = "us-central1-b"
    }
    prod = {
      project = "gcp-project-prod"
      region  = "us-central1"
      zone    = "us-central1-c"
    }
  }
}

locals {
  common = var.common[terraform.workspace]
}