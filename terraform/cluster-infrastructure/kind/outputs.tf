output "kind_cluster" {
  value = {
    endpoint = kind_cluster.local.endpoint
    cluster_ca_certificate = kind_cluster.local.cluster_ca_certificate
    client_certificate = kind_cluster.local.client_certificate
    client_key = kind_cluster.local.client_key
    kube_context = jsondecode(jsonencode(yamldecode(kind_cluster.local.kubeconfig).contexts))[0].name
    kubeconfig = kind_cluster.local.kubeconfig
    kubeconfig_path = kind_cluster.local.kubeconfig_path
  }
}
