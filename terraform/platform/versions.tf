terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.9.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    gitea = {
      source  = "Lerentis/gitea"
      version = "0.12.2"
    }
  }
}

provider "kubernetes" {
  host = data.terraform_remote_state.kind_cluster.outputs.m3_demo_cluster.endpoint

  client_certificate     = data.terraform_remote_state.kind_cluster.outputs.m3_demo_cluster.client_certificate
  client_key             = data.terraform_remote_state.kind_cluster.outputs.m3_demo_cluster.client_key
  cluster_ca_certificate = data.terraform_remote_state.kind_cluster.outputs.m3_demo_cluster.cluster_ca_certificate
}

provider "kubectl" {
  host = data.terraform_remote_state.kind_cluster.outputs.m3_demo_cluster.endpoint

  client_certificate     = data.terraform_remote_state.kind_cluster.outputs.m3_demo_cluster.client_certificate
  client_key             = data.terraform_remote_state.kind_cluster.outputs.m3_demo_cluster.client_key
  cluster_ca_certificate = data.terraform_remote_state.kind_cluster.outputs.m3_demo_cluster.cluster_ca_certificate
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    config_path = data.terraform_remote_state.kind_cluster.outputs.m3_demo_cluster.kubeconfig_path
    config_context = data.terraform_remote_state.kind_cluster.outputs.m3_demo_cluster.kube_context
  }
}

provider "gitea" {
  insecure = true
  base_url = "http://localhost:30030"
  username = "ok-admin"
  password= "ok-admin"
}
