resource "kubernetes_deployment" "evidently" {
  metadata {
    name      = "evidently"
    namespace = kubernetes_namespace.observability.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "evidently"
      }
    }
    template {
      metadata {
        labels = {
          app = "evidently"
        }
      }
      spec {
        container {
          image = "evidently"
          image_pull_policy = "Never"
          name  = "evidently"
          port {
            container_port = 8085
          }
        }
      }
    }
  }
}
