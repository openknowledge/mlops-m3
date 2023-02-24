terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.9.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    gitea = {
      source  = "Lerentis/gitea"
      version = "0.12.2"
    }
  }
}

provider "gitea" {
  insecure = true
  base_url = "http://gitea.local"
  username = "ok-admin"
  password= "ok-admin"
}
