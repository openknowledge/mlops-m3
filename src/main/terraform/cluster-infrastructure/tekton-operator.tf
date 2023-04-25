data "http" "tekton_operator_release" {
  url = "https://storage.googleapis.com/tekton-releases/operator/previous/v0.64.0/release.yaml"
}

data "kubectl_file_documents" "tekton_operator_release" {
  content = data.http.tekton_operator_release.response_body
}

resource "kubernetes_namespace" "tekton-operator" {
  metadata {
    name = "tekton-operator"
  }
  lifecycle {
    ignore_changes = [
      metadata.0.annotations["operator.tekton.dev/prune.hash"]
    ]
  }
}

resource "kubernetes_namespace" "tekton-pipelines" {
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
  depends_on = [kubernetes_namespace.tekton-operator, kubernetes_namespace.tekton-pipelines]

  for_each  = data.kubectl_file_documents.tekton_operator_release.manifests
  yaml_body = each.value
}

resource "kubectl_manifest" "tekton_operator_config" {
  depends_on = [kubectl_manifest.tekton_operator]
  yaml_body = file("${path.module}/tekton-config.yaml")
}

resource "kubernetes_ingress_v1" "tekton_dashboard" {
  depends_on = [kubectl_manifest.tekton_operator, null_resource.wait_for_ingress_nginx]

  metadata {
    name      = "tekton-dashboard-ingress"
    namespace = kubernetes_namespace.tekton-pipelines.metadata.0.name
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
