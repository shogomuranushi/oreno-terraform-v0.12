variable "gke" {
  type = map(map(string))
  default = {
    dev = {
      vpc_name           = "vpc-dev"
      k8s_version        = "1.14.7-gke.23"
      k8s_name           = "gke_dev"
      initial_node_count = 1
      min_node_count     = 3
      max_node_count     = 6
      machine_type       = "n1-standard-2"
      disk_size_gb       = 30
    }
    stg = {
      vpc_name           = "vpc-stg"
      k8s_version        = "1.14.7-gke.23"
      k8s_name           = "gke_stg"
      initial_node_count = 1
      min_node_count     = 3
      max_node_count     = 6
      machine_type       = "n1-standard-2"
      disk_size_gb       = 30
    }
    us-central1-prod = {
      vpc_name           = "vpc-prod"
      k8s_version        = "1.14.7-gke.23"
      k8s_name           = "gke_prod"
      initial_node_count = 1
      min_node_count     = 3
      max_node_count     = 100
      machine_type       = "n1-standard-2"
      disk_size_gb       = 50
    }
  }
}

locals {
  gke = var.gke[terraform.workspace]
}

resource "google_project_service" "gke" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_container_cluster" "master" {
  provider = "google-beta"

  name               = local.gke.k8s_name
  min_master_version = local.gke.k8s_version

  location = local.common.region
  network    = local.gke.vpc_name
  subnetwork = local.gke.vpc_name

  remove_default_node_pool = true
  initial_node_count       = 1

  vertical_pod_autoscaling {
    enabled = true
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }

    kubernetes_dashboard {
      disabled = false
    }

    network_policy_config {
      disabled = false
    }

    istio_config {
      disabled = false
    }

    cloudrun_config {
      disabled = false
    }
  }

  enable_tpu = true
  ip_allocation_policy {
    use_ip_aliases = true
  }

  workload_identity_config {
    identity_namespace = "${local.common.project}.svc.id.goog"
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  resource_usage_export_config {
    enable_network_egress_metering = true
    bigquery_destination {
      dataset_id = "gke_cluster_resource_usage"
    }
  }
}

resource "google_container_node_pool" "default-node-pool" {
  provider = "google-beta"

  name           = "${local.gke.k8s_name}-default-node-pool"
  cluster        = google_container_cluster.master.name
  location       = local.common.region
  node_locations = ["${local.common.zone}"]

  initial_node_count = local.gke.initial_node_count

  node_config {
    preemptible  = true
    machine_type = local.gke.machine_type
    disk_size_gb = local.gke.disk_size_gb

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
  }

  management {
    auto_repair = true
  }

  autoscaling {
    min_node_count = local.gke.min_node_count
    max_node_count = local.gke.max_node_count
  }
}