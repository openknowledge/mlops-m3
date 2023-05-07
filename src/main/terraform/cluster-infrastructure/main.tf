module "kind_cluster" {
  source = "./kind"

  env_repo_path = var.env_repo_path
  docker_daemon_json_path = var.docker_daemon_json_path
  repository_path = var.repository_path
}

resource "kubernetes_namespace" "infrastructure" {
  metadata {
    annotations = {
      name = "infrastructure-namespace"
    }
    name = "infrastructure"
  }

  lifecycle {
    ignore_changes = [
      metadata.0.annotations["operator.tekton.dev/prune.hash"]
    ]
  }
}

resource "kubernetes_namespace" "production" {
  metadata {
    annotations = {
      name = "production-namespace"
    }
    name = "production"
  }

  lifecycle {
    ignore_changes = [
      metadata.0.annotations["operator.tekton.dev/prune.hash"]
    ]
  }
}

module "gitea" {
  depends_on = [module.kind_cluster]

  source = "./gitea-registry"

  namespace = kubernetes_namespace.infrastructure.metadata.0.name
}

module "docker_registry" {
  depends_on = [module.kind_cluster]

  source = "./docker-registry"

  namespace = kubernetes_namespace.infrastructure.metadata.0.name
}

module "ingress-controller" {
  depends_on = [module.kind_cluster]

  source = "./ingress-controller"
}

data "http" "tekton_operator_release" {
  url = "https://storage.googleapis.com/tekton-releases/operator/previous/v0.64.0/release.yaml"
}

data "kubectl_file_documents" "tekton_operator_release" {
  content = data.http.tekton_operator_release.response_body
}

module "tekton_operator" {
  depends_on = [module.kind_cluster, module.ingress-controller]

  source = "./tekton-operator"

  tekton_operator_release = data.kubectl_file_documents.tekton_operator_release.manifests
}
