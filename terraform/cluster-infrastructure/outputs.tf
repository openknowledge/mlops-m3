output "m3_demo_cluster" {
  value = {
    endpoint = module.kind_cluster.m3_demo_cluster.endpoint
    cluster_ca_certificate = module.kind_cluster.m3_demo_cluster.cluster_ca_certificate
    client_certificate = module.kind_cluster.m3_demo_cluster.client_certificate
    client_key = module.kind_cluster.m3_demo_cluster.client_key
    kube_context = jsondecode(jsonencode(yamldecode(module.kind_cluster.m3_demo_cluster.kubeconfig).contexts))[0].name
    kubeconfig = module.kind_cluster.m3_demo_cluster.kubeconfig
    kubeconfig_path = module.kind_cluster.m3_demo_cluster.kubeconfig_path
  }
}
