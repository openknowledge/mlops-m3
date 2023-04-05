resource "kubernetes_namespace" "cicd" {
  metadata {
    annotations = {
      name = "cicd-namespace"
    }

    name = "cicd"
  }
  lifecycle {
    ignore_changes = [
      metadata.0.annotations["operator.tekton.dev/prune.hash"]
    ]
  }
}