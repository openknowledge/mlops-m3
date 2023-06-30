output "kind_cluster" {
  value = {
    endpoint = module.kind.kind_cluster.endpoint
    cluster_ca_certificate = module.kind.kind_cluster.cluster_ca_certificate
    client_certificate = module.kind.kind_cluster.client_certificate
    client_key = module.kind.kind_cluster.client_key
    kube_context = jsondecode(jsonencode(yamldecode(module.kind.kind_cluster.kubeconfig).contexts))[0].name
    kubeconfig = module.kind.kind_cluster.kubeconfig
    kubeconfig_path = module.kind.kind_cluster.kubeconfig_path
  }
}

output "gitea_credentials" {
  value = {
    username = var.gitea_admin_username
    password = var.gitea_admin_password
  }
}