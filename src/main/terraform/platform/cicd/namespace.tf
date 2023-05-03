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

resource "kubernetes_limit_range" "limit_range_for_tekton" {
  metadata {
    name = "tekton-limit-range"
    namespace = "cicd"
  }
  spec {
    limit {
      type = "Container"
      min = {
        cpu    = "100m"
        memory = "1Gi"
      }
      max = {
        cpu    = "2000m"
        memory = "8Gi"
      }
      default = {
        cpu    = "700m"
        memory = "1Gi"
      }
      default_request = {
        cpu    = "700m"
        memory = "1Gi"
      }
    }
  }
}