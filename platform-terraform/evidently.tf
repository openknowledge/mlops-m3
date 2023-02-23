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
        // TODO: Currently needs to be build manually. As soon as we have the App in this Repo, we can let terraform build the image on its own.
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
