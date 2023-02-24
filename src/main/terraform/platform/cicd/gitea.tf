resource "gitea_user" "ok-user" {
  username             = "ok-user"
  login_name           = "ok-user"
  password             = "Password1234!"
  email                = "ok-user@user.dev"
  must_change_password = false
}

resource "gitea_repository" "ok-gitea-repository" {
  username     = gitea_user.ok-user.username
  name         = "ok-gitea-repository"
  private      = true
  issue_labels = "Default"
  license      = "MIT"
}
