output "m3-demo-cluster" {
  value = {
    endpoint = kind_cluster.m3-demo-cluster.endpoint
    cluster_ca_certificate = kind_cluster.m3-demo-cluster.cluster_ca_certificate
    client_certificate = kind_cluster.m3-demo-cluster.client_certificate
    client_key = kind_cluster.m3-demo-cluster.client_key
    kube_context = jsondecode(jsonencode(yamldecode(kind_cluster.m3-demo-cluster.kubeconfig).contexts))[0].name
    kubeconfig = kind_cluster.m3-demo-cluster.kubeconfig
    kubeconfig_path = kind_cluster.m3-demo-cluster.kubeconfig_path
  }
}
