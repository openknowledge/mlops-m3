resource "helm_release" "gitea-registry" {
  name             = "gitea"
  namespace        = var.namespace
  create_namespace = false

  repository = "https://dl.gitea.io/charts"
  chart      = "gitea"
  version = "8.3.0"

  values = [
    file("${path.module}/gitea-values.yml")
  ]
}