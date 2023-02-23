resource "helm_release" "prometheus-operator" {
  name             = "gitea"
  namespace        = "cicd"
  create_namespace = false

  repository = "https://dl.gitea.io/charts"
  chart      = "gitea"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    "${file("cicd/gitea-values.yml")}"
  ]
}
