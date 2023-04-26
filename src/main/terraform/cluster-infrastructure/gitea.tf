resource "helm_release" "gitea-registry" {
  name             = "gitea"
  namespace        = kubernetes_namespace.infrastructure.metadata.0.name
  create_namespace = false

  repository = "https://dl.gitea.io/charts"
  chart      = "gitea"

  values = [
    file("gitea-values.yml")
  ]
}