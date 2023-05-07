output "m3-demo-cluster" {
  value = {
    endpoint = module.kind_cluster.m3-demo-cluster.endpoint
    cluster_ca_certificate = module.kind_cluster.m3-demo-cluster.cluster_ca_certificate
    client_certificate = module.kind_cluster.m3-demo-cluster.client_certificate
    client_key = module.kind_cluster.m3-demo-cluster.client_key
    kube_context = jsondecode(jsonencode(yamldecode(module.kind_cluster.m3-demo-cluster.kubeconfig).contexts))[0].name
    kubeconfig = module.kind_cluster.m3-demo-cluster.kubeconfig
    kubeconfig_path = module.kind_cluster.m3-demo-cluster.kubeconfig_path
  }
}
