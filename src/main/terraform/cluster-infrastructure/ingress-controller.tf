resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  namespace        = "ingress-nginx"
  create_namespace = true

  values = [file("ingress-nginx-values.yml")]

  depends_on = [kind_cluster.m3-demo-cluster]
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
      for i in 1 2 3 4 5; do kubectl create --filename test-ingress.yaml && kubectl delete --filename test-ingress.yaml && break || sleep 15; done
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}