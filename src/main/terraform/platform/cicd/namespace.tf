resource "kubernetes_namespace" "cicd" {
  metadata {
    annotations = {
      name = "cicd-namespace"
    }
    name = "cicd"
  }
}