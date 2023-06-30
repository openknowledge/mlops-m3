data "terraform_remote_state" "cluster_infrastructure" {
  backend = "local"

  config = {
    path = "../cluster-infrastructure/terraform.tfstate"
  }
}

module "observability" {
  source = "./observability"
}

module "gitea" {
  source = "./gitea"

  gitea_user_name     = var.gitea_user_name
  gitea_user_password = var.gitea_user_password
  gitea_user_email    = var.gitea_user_email
  gitea_application_repository_name = var.gitea_application_repository_name
  gitea_environment_repository_name = var.gitea_environment_repository_name
}

module "cicd" {
  depends_on = [module.gitea]
  source     = "./cicd"

  gitea_env_repository_name = module.gitea.gitea_registry.gitea_env_repository_name
  gitea_repository_name     = module.gitea.gitea_registry.gitea_repository_name
  gitea_user_name           = module.gitea.gitea_registry.gitea_user_name
  gitea_user_email          = module.gitea.gitea_registry.gitea_user_email
  gitea_password            = module.gitea.gitea_registry.gitea_password
}
