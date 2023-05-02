resource "kubernetes_deployment" "registry" {
  metadata {
    name      = "docker-registry"
    namespace = kubernetes_namespace.infrastructure.metadata.0.name
    labels = {
      app = "docker-registry"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "docker-registry"
      }
    }
    template {
      metadata {
        labels = {
          app = "docker-registry"
        }
      }
      spec {
        container {
          image = "registry:2"
          image_pull_policy = "IfNotPresent"
          name  = "registry"
          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "registry" {
  metadata {
    name      = "registry-service"
    namespace = kubernetes_namespace.infrastructure.metadata.0.name
  }

  spec {
    selector = {
      app = kubernetes_deployment.registry.metadata.0.labels.app
    }

    type = "NodePort"

    port {
      port = 5000
      target_port = 5000
      node_port = 30050
    }
  }
}
