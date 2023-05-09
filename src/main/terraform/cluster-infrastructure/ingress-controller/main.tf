resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }

  lifecycle {
    ignore_changes = [
      metadata.0.annotations["operator.tekton.dev/prune.hash"]
    ]
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  namespace        = kubernetes_namespace.ingress_nginx.metadata.0.name
  create_namespace = false

  values = [file("${path.module}/ingress-nginx-values.yml")]
}

resource "null_resource" "wait_for_ingress_nginx" {
  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"
      kubectl wait --namespace ${helm_release.ingress_nginx.namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
      printf "\nNow waiting for the nginx ingress validatingwebhookconfigurations...\n"
      for i in 1 2 3 4 5; do kubectl create --filename ${path.module}/test-ingress.yaml && kubectl delete --filename ${path.module}/test-ingress.yaml && break || sleep 15; done
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}