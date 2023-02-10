resource "helm_release" "prometheus-operator" {
  name             = "prometheus-operator-controller"
  namespace        = "observability"
  create_namespace = false

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    "${file("prometheus-operator-values.yml")}"
  ]
}
