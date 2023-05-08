variable "gitea_user_name" {
  type = string
  default = "ok-user"
}

variable "gitea_user_password" {
  type = string
  default = "Password1234!"
}

variable "gitea_user_email" {
  type = string
  default = "ok-user@user.dev"
}

variable "gitea_application_repository_name" {
  type = string
    default = "ok-gitea-repository"
}

variable "gitea_environment_repository_name" {
  type = string
  default = "environment-repository"
}
