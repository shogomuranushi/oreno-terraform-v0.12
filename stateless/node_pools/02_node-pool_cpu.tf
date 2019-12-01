### custom-1-4096
variable "node_pool_cpu_custom-1-4096" {
  type = map(map(string))
  default = {
    dev = {
      k8s_name       = "gke_dev"
      machine_type   = "custom-1-4096"
      disk_size_gb   = 50
      min_node_count = 0
      max_node_count = 1000
    }
    stg = {
      k8s_name       = "gke_stg"
      machine_type   = "custom-1-4096"
      disk_size_gb   = 50
      min_node_count = 0
      max_node_count = 1000
    }
    us-central1-prod = {
      k8s_name       = "gke_prod"
      machine_type   = "custom-1-4096"
      disk_size_gb   = 50
      min_node_count = 0
      max_node_count = 1000
    }
  }
}

module "node_pool_cpu_custom-1-4096" {
  source = "./modules/node_pool_cpu"

  common    = local.common
  node_pool = var.node_pool_cpu_custom-1-4096[terraform.workspace]
}