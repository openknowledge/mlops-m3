output "m3_demo_cluster" {
  value = {
    endpoint = kind_cluster.m3_demo_cluster.endpoint
    cluster_ca_certificate = kind_cluster.m3_demo_cluster.cluster_ca_certificate
    client_certificate = kind_cluster.m3_demo_cluster.client_certificate
    client_key = kind_cluster.m3_demo_cluster.client_key
    kube_context = jsondecode(jsonencode(yamldecode(kind_cluster.m3_demo_cluster.kubeconfig).contexts))[0].name
    kubeconfig = kind_cluster.m3_demo_cluster.kubeconfig
    kubeconfig_path = kind_cluster.m3_demo_cluster.kubeconfig_path
  }
}
