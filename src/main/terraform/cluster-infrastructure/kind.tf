resource "kind_cluster" "m3-demo-cluster" {
  name           = "m3-demo-cluster"
  wait_for_ready = true
  kubeconfig_path = pathexpand("~/.kube/config")

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 443
        host_port      = 443
        protocol       = "TCP"
      }
    }
  }
}

resource "null_resource" "load_evidently_to_kind" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the cluster to be created...\n"
      kind load docker-image -n m3-demo-cluster evidently
    EOF
  }

  depends_on = [kind_cluster.m3-demo-cluster]
}

output "m3-demo-cluster" {
  value = {
    endpoint = kind_cluster.m3-demo-cluster.endpoint
    cluster_ca_certificate = kind_cluster.m3-demo-cluster.cluster_ca_certificate
    client_certificate = kind_cluster.m3-demo-cluster.client_certificate
    client_key = kind_cluster.m3-demo-cluster.client_key
    kubeconfig_path = kind_cluster.m3-demo-cluster.kubeconfig_path
    kube_context = jsondecode(jsonencode(yamldecode(kind_cluster.m3-demo-cluster.kubeconfig).contexts))[0].name
  }
}