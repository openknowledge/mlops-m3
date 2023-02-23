resource "kubernetes_namespace" "observability" {
  metadata {
    annotations = {
      name = "observability-namespace"
    }
    name = "observability"
  }
}