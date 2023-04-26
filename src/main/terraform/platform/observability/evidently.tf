resource "kubernetes_deployment" "evidently" {
  metadata {
    name      = "evidently-deployment"
    namespace = kubernetes_namespace.observability.metadata.0.name
    labels = {
      app = "evidently"
    }
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

resource "kubernetes_service" "evidently" {
  metadata {
    name      = "evidently-service"
    namespace = kubernetes_namespace.observability.metadata.0.name
  }

  spec {
    selector = {
      app = kubernetes_deployment.evidently.metadata.0.labels.app
    }

    type = "NodePort"

    port {
      port = 80
      target_port = 8085
      node_port = 30085
    }
  }
}

resource "kubernetes_ingress_v1" "evidently" {
  metadata {
    name      = "evidently-ingress"
    namespace = kubernetes_namespace.observability.metadata.0.name
  }

  spec {
    rule {
      host = "evidently.localhost"
      http {
        path {
          backend {
            service {
              name = kubernetes_service.evidently.metadata.0.name
              port {
                number = kubernetes_service.evidently.spec.0.port.0.port
              }
            }
          }
        }
      }
    }
  }
}
