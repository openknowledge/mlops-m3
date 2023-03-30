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
  }
}

data "terraform_remote_state" "m3-kind-cluster" {
  backend = "local"

  config = {
    path = "../cluster-infrastructure/terraform.tfstate"
  }
}

provider "kubernetes" {
  host = data.terraform_remote_state.m3-kind-cluster.outputs.m3-demo-cluster.endpoint

  client_certificate     = data.terraform_remote_state.m3-kind-cluster.outputs.m3-demo-cluster.client_certificate
  client_key             = data.terraform_remote_state.m3-kind-cluster.outputs.m3-demo-cluster.client_key
  cluster_ca_certificate = data.terraform_remote_state.m3-kind-cluster.outputs.m3-demo-cluster.cluster_ca_certificate
}

provider "kubectl" {
  host = data.terraform_remote_state.m3-kind-cluster.outputs.m3-demo-cluster.endpoint

  client_certificate     = data.terraform_remote_state.m3-kind-cluster.outputs.m3-demo-cluster.client_certificate
  client_key             = data.terraform_remote_state.m3-kind-cluster.outputs.m3-demo-cluster.client_key
  cluster_ca_certificate = data.terraform_remote_state.m3-kind-cluster.outputs.m3-demo-cluster.cluster_ca_certificate
  load_config_file       = false
}

provider "helm" {
    kubernetes {
      config_path = data.terraform_remote_state.m3-kind-cluster.outputs.m3-demo-cluster.kubeconfig_path
      config_context = data.terraform_remote_state.m3-kind-cluster.outputs.m3-demo-cluster.kube_context
  }
}

module "observability" {
  source = "./observability"
}

module "cicd" {
  source = "./cicd"
}