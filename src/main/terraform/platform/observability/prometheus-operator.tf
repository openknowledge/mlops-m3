resource "helm_release" "prometheus-operator" {
  name             = "prometheus-operator-controller"
  namespace        = kubernetes_namespace.observability.metadata.0.name
  create_namespace = false

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    "${file("observability/prometheus-operator-values.yml")}"
  ]
}

resource "kubernetes_pod" "pushgateway" {
  metadata {
    name      = "prom-pushgateway"
    namespace = kubernetes_namespace.observability.metadata.0.name
    labels = {
      pushgateway_instance = "pushgateway"
    }
  }

  spec {
    container {
      image = "prom/pushgateway"
      name  = "prom-pushgateway"

      port {
        container_port = 9091
      }
    }
  }
}

resource "kubernetes_service" "pushgateway-service" {
  metadata {
    name      = "pushgateway-service"
    namespace = kubernetes_namespace.observability.metadata.0.name
  }

  spec {
    selector = {
      pushgateway_instance = "pushgateway"
    }

    type = "ClusterIP"

    port {
      port = 9091
      target_port = 9091
    }
  }
}
