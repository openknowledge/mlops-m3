resource "kubernetes_namespace" "observability" {
  metadata {
    annotations = {
      name = "observability-namespace"
    }
    name = "observability"
  }

  lifecycle {
    ignore_changes = [
      metadata.0.annotations["operator.tekton.dev/prune.hash"]
    ]
  }
}