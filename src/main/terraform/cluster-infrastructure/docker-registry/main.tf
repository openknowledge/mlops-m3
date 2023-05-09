resource "kubernetes_deployment" "registry" {
  metadata {
    name      = "docker-registry"
    namespace = var.namespace
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
    namespace = var.namespace
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

resource "kubernetes_ingress_v1" "registry" {
  metadata {
    name      = "registry-ingress"
    namespace = var.namespace
  }

  spec {
    rule {
      host = "docker.localhost"
      http {
        path {
          backend {
            service {
              name = kubernetes_service.registry.metadata.0.name
              port {
                number = kubernetes_service.registry.spec.0.port.0.port
              }
            }
          }
        }
      }
    }
  }
}
