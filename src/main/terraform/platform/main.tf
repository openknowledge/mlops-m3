data "terraform_remote_state" "kind_cluster" {
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
}

module "cicd" {
  depends_on = [module.gitea]
  source = "./cicd"

  gitea_env_repository_name = module.gitea.gitea_registry.gitea_env_repository_name
  gitea_repository_name = module.gitea.gitea_registry.gitea_repository_name
  gitea_username = module.gitea.gitea_registry.gitea_username
  gitea_password = module.gitea.gitea_registry.gitea_password
}
