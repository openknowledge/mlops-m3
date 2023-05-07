terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.20.0"
    }
    kind = {
      source  = "tehcyx/kind"
      version = "0.0.16"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
  }
}

provider "kind" {
}

provider "kubectl" {
  host                   = module.kind_cluster.m3_demo_cluster.endpoint
  cluster_ca_certificate = module.kind_cluster.m3_demo_cluster.cluster_ca_certificate
  client_certificate     = module.kind_cluster.m3_demo_cluster.client_certificate
  client_key             = module.kind_cluster.m3_demo_cluster.client_key

  load_config_file = false
}

provider "helm" {
  kubernetes {
    config_path    = module.kind_cluster.m3_demo_cluster.kubeconfig_path
    config_context = jsondecode(jsonencode(yamldecode(module.kind_cluster.m3_demo_cluster.kubeconfig).contexts))[0].name
  }
}

provider "kubernetes" {
  host = module.kind_cluster.m3_demo_cluster.endpoint

  client_certificate     = module.kind_cluster.m3_demo_cluster.client_certificate
  client_key             = module.kind_cluster.m3_demo_cluster.client_key
  cluster_ca_certificate = module.kind_cluster.m3_demo_cluster.cluster_ca_certificate
}
