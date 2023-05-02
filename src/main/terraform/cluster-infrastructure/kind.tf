resource "kind_cluster" "m3-demo-cluster" {
  name           = "m3-demo-cluster"
  wait_for_ready = true
  kubeconfig_path = pathexpand("~/.kube/config")

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      extra_mounts {
          host_path      = var.repository-path
          container_path = "/m3-demo"
      }

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

      # Extra port mappings for Gitea
      extra_port_mappings {
        container_port = 30030
        host_port      = 30030
        protocol       = "TCP"
      }

      # Extra port mappings for Tekton Dashboard
      extra_port_mappings {
        container_port = 30097
        host_port      = 30097
        protocol       = "TCP"
      }

      # Extra port mappings for Prometheus
      extra_port_mappings {
        container_port = 30090
        host_port      = 30090
        protocol       = "TCP"
      }

      # Extra port mappings for Grafana
      extra_port_mappings {
        container_port = 30031
        host_port      = 30031
        protocol       = "TCP"
      }

      # Extra port mappings for Evidently
      extra_port_mappings {
        container_port = 30085
        host_port      = 30085
        protocol       = "TCP"
      }

      # Extra port mappings for Docker Registry
      extra_port_mappings {
        container_port = 30050
        host_port      = 30050
        protocol       = "TCP"
      }
    }
  }
}

variable "repository-path" {
  default = "../../../../insurance-prediction"
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