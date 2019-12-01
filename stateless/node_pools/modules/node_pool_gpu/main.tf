variable "common" {}
variable "node_pool" {}

locals {
  preemptible = [
    "false"
  ]
}

resource "google_container_node_pool" "gpu" {
  provider = "google-beta"
  count    = length(local.preemptible)

  name           = "${var.node_pool.machine_type}-${element(split("-", var.node_pool.guest_accelerator_type), 2)}-${var.node_pool.guest_accelerator_count}-${local.preemptible[count.index]}"
  cluster        = var.node_pool.k8s_name
  location       = var.common.region
  node_locations = ["${var.common.zone}"]

  initial_node_count = 0

  node_config {
    preemptible  = local.preemptible[count.index]
    machine_type = var.node_pool.machine_type
    disk_size_gb = var.node_pool.disk_size_gb

    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]

    guest_accelerator {
      type  = var.node_pool.guest_accelerator_type
      count = var.node_pool.guest_accelerator_count
    }

    taint {
      key    = "spot"
      value  = local.preemptible[count.index]
      effect = "NO_SCHEDULE"
    }
    tags = ["node"]
  }

  management {
    auto_repair = true
  }

  autoscaling {
    min_node_count = var.node_pool.min_node_count
    max_node_count = var.node_pool.max_node_count
  }
}
