### k80-1
variable "node_pool_k80-1" {
  type = map(map(string))
  default = {
    dev = {
      k8s_name                = "gke_dev"
      machine_type            = "custom-4-53248-ext"
      disk_size_gb            = 50
      min_node_count          = 0
      max_node_count          = 1000
      guest_accelerator_type  = "nvidia-tesla-k80"
      guest_accelerator_count = 1
    }
    stg = {
      k8s_name                = "gke_stg"
      machine_type            = "custom-4-53248-ext"
      disk_size_gb            = 50
      min_node_count          = 0
      max_node_count          = 1000
      guest_accelerator_type  = "nvidia-tesla-k80"
      guest_accelerator_count = 1
    }
    us-central1-prod = {
      k8s_name                = "gke_prod"
      machine_type            = "custom-4-53248-ext"
      disk_size_gb            = 50
      min_node_count          = 0
      max_node_count          = 1000
      guest_accelerator_type  = "nvidia-tesla-k80"
      guest_accelerator_count = 1
    }
  }
}

module "node_pool_k80-1" {
  source = "./modules/node_pool_gpu"

  common    = local.common
  node_pool = var.node_pool_k80-1[terraform.workspace]
}