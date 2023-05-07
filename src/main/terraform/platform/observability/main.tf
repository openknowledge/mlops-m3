resource "kubernetes_namespace" "observability" {
  metadata {
    annotations = {
      name = "observability-namespace"
    }
    name = "observability"
  }

  lifecycle {
    ignore_changes = [
      metadata.0.annotations["operator.tekton.dev/prune.hash"]
    ]
  }
}

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
    file("${path.module}/prometheus-operator-values.yml")
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

resource "kubernetes_config_map_v1" "evidently_dashboard" {
    metadata {
        name      = "evidently-dashboard"
        namespace = kubernetes_namespace.observability.metadata.0.name
      labels = {
        grafana_dashboard: 1
      }
    }

    data = {
      "evidently-dashboard.json" = file("${path.module}/dashboards/evidently-dashboard.json")
    }
}