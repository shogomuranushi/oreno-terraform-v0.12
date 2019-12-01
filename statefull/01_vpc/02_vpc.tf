variable "vpc" {
  type = map(map(string))
  default = {
    dev = {
      name          = "vpc-dev"
      ip_cidr_range = "10.10.0.0/16"
    }
    stg = {
      name          = "vpc-stg"
      ip_cidr_range = "10.11.0.0/16"
    }
    us-central1-prod = {
      name          = "vpc-prod"
      ip_cidr_range = "10.12.0.0/16"
    }
  }
}

locals {
  vpc = var.vpc[terraform.workspace]
}

resource "google_compute_network" "main" {
  name                    = local.vpc.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = local.vpc.name
  ip_cidr_range = local.vpc.ip_cidr_range
  region        = local.common.region
  network       = google_compute_network.main.self_link
}