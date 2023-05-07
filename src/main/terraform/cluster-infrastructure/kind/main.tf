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
        host_path      = var.repository_path
        container_path = "/m3-demo"
      }

      extra_mounts {
        host_path      = var.env_repo_path
        container_path = "/m3-env"
      }

      extra_mounts {
        host_path      = var.docker_daemon_json_path
        container_path = "/etc/docker/daemon.json"
      }

      kubeadm_config_patches = [
        <<-EOT
          kind: InitConfiguration
          nodeRegistration:
            kubeletExtraArgs:
              node-labels: "ingress-ready=true"
        EOT
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

      # Extra port mappings for Insurance Prediction App
      extra_port_mappings {
        container_port = 30080
        host_port      = 30080
        protocol       = "TCP"
      }
    }
  }
}
