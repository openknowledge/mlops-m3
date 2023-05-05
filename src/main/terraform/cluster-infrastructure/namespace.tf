resource "kubernetes_namespace" "infrastructure" {
  metadata {
    annotations = {
      name = "infrastructure-namespace"
    }
    name = "blah"
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
