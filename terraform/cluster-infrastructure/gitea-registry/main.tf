resource "helm_release" "gitea-registry" {
  name             = "gitea"
  namespace        = var.namespace
  create_namespace = false

  repository = "https://dl.gitea.io/charts"
  chart      = "gitea"
  version = "8.3.0"

  values = [templatefile("${path.module}/gitea-values.yml", {
    gitea_admin_username = var.admin_username
    gitea_admin_password = var.admin_password
  })]
}