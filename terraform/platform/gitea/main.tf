resource "gitea_user" "ok-user" {
  username             = var.gitea_user_name
  login_name           = var.gitea_user_name
  password             = var.gitea_user_password
  email                = var.gitea_user_email
  must_change_password = false
}

resource "gitea_repository" "ok-gitea-repository" {
  username     = gitea_user.ok-user.username
  name         = var.gitea_application_repository_name
  private      = false
  issue_labels = "Default"
  license      = "MIT"
}

resource "gitea_repository" "environment-repository" {
  username     = gitea_user.ok-user.username
  name         = var.gitea_environment_repository_name
  private      = false
  issue_labels = "Default"
  license      = "MIT"
}

locals {
  basic_auth = base64encode("${gitea_user.ok-user.username}:${gitea_user.ok-user.password}")
}

resource "null_resource" "create-push-webhook" {
  provisioner "local-exec" {
    command = <<EOF
      printf "\nCreating a Webhook for the Push Trigger in Gitea: \n"
      curl -d '{"type": "gitea", "config": { "url": "http://el-ci-listener.cicd.svc.cluster.local:8080", "content_type": "json"}, "events": ["push"], "active": true}' \
        -H "Content-Type: application/json" \
        -H "authorization: Basic ${local.basic_auth}" \
        -X POST http://localhost:30030/api/v1/repos/${gitea_user.ok-user.username}/${gitea_repository.ok-gitea-repository.name}/hooks
    EOF
  }
}