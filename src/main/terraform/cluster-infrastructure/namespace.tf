resource "kubernetes_namespace" "infrastructure" {
  metadata {
    annotations = {
      name = "infrastructure-namespace"
    }
    name = "infrastructure"
  }
}