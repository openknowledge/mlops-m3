resource "kubernetes_namespace" "tekton_operator" {
  metadata {
    name = "tekton-operator"
  }
  lifecycle {
    ignore_changes = [
      metadata.0.annotations["operator.tekton.dev/prune.hash"]
    ]
  }
}

resource "kubernetes_namespace" "tekton_pipelines" {
  metadata {
    name = "tekton-pipelines"
  }
  lifecycle {
    ignore_changes = [
      metadata.0.annotations["operator.tekton.dev/prune.hash"]
    ]
  }
}

resource "kubectl_manifest" "tekton_operator" {
  depends_on = [kubernetes_namespace.tekton_operator, kubernetes_namespace.tekton_pipelines]

  for_each  = var.tekton_operator_release
  yaml_body = each.value
}

resource "kubectl_manifest" "tekton_operator_config" {
  depends_on = [kubectl_manifest.tekton_operator]
  yaml_body  = file("${path.module}/tekton-config.yaml")
}

resource "kubernetes_service_v1" "tekton_dashboard" {
  metadata {
    name      = "tekton-dashboard"
    namespace = kubernetes_namespace.tekton_pipelines.metadata.0.name
  }

  spec {
    selector = {
      "app.kubernetes.io/component" = "dashboard"
      "app.kubernetes.io/instance" = "default"
      "app.kubernetes.io/name" = "dashboard"
      "app.kubernetes.io/part-of" = "tekton-dashboard"
    }
    port {
      name        = "http"
      port        = 9097
      node_port   = 30097
      target_port = 9097
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "tekton_dashboard" {
  depends_on = [kubectl_manifest.tekton_operator]

  metadata {
    name      = "tekton-dashboard-ingress"
    namespace = kubernetes_namespace.tekton_pipelines.metadata.0.name
  }

  spec {
    rule {
      host = "tekton.localhost"
      http {
        path {
          backend {
            service {
              name = "tekton-dashboard"
              port {
                number = 9097
              }
            }
          }
        }
      }
    }
  }
}
