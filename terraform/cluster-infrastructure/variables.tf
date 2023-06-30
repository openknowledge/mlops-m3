variable "repository_path" {
  description = "The path to the application that should be managed by Tekton"
}

variable "env_repo_path" {
  description = "The enironment repository that holds the kustomize files for deployment of the application via tekton"
}

variable "docker_daemon_json_path" {
  description = "The path to the docker daemon json file"
  default     = "docker-registry/docker-daemon.json"
}

variable "cluster_name" {
  description = "The name of the cluster"
  default = "demo-cluster"
}

variable "gitea_admin_username" {
  type    = string
  default = "admin"
}

variable "gitea_admin_password" {
  type    = string
  default = "admin"
}