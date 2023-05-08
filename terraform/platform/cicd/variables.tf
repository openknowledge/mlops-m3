variable "gitea_user_name" {
  description = "Gitea username"
  default     = "user"
}

variable "gitea_user_email" {
  description = "Gitea user email"
  default     = "user@user.dev"
}

variable "gitea_password" {
  description = "Gitea password"
  default     = "user"
}

variable "gitea_repository_name" {
  description = "Gitea repository"
  default     = "gitea-repository"
}

variable "gitea_env_repository_name" {
    description = "Environment repository name"
    default     = "environment-repository"
}