output "gitea_registry" {
  value = {
    gitea_user_name            = gitea_user.ok-user.username
    gitea_user_email            = gitea_user.ok-user.email
    gitea_password            = gitea_user.ok-user.password
    gitea_repository_name     = gitea_repository.ok-gitea-repository.name
    gitea_env_repository_name = gitea_repository.environment-repository.name
  }
}