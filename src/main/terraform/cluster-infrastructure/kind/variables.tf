variable "repository_path" {
  description = "The path to the application that should be managed by Tekton"
  default     = "../../../../insurance-prediction"
}

variable "env_repo_path" {
  description = "The enironment repository that holds the kustomize files for deployment of the application via tekton"
  default     = "../../../../environment-repository"
}

variable "docker_daemon_json_path" {
  description = "The path to the docker daemon json file"
  default     = "docker-registry/docker-daemon.json"
}