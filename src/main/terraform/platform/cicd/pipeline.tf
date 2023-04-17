resource "kubectl_manifest" "ci_pipeline" {
  yaml_body = file("${path.module}/tekton/ci-pipeline.yaml")
}

data "http" "git_clone_task" {
  url = "https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.6/git-clone.yaml"
}

data "http" "git_cli_task" {
  url = "https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-cli/0.4/git-cli.yaml"
}


resource "kubectl_manifest" "git_cli_task" {
  override_namespace = kubernetes_namespace.cicd.metadata.0.name
  yaml_body          = data.http.git_cli_task.response_body
}

resource "kubectl_manifest" "git_clone_task" {
  override_namespace = kubernetes_namespace.cicd.metadata.0.name
  yaml_body          = data.http.git_clone_task.response_body
}

resource "random_uuid" "ci_pipeline_run_uuid" {}

# to re-run the pipeline-run with the next apply, just use terraform apply -replace=module.cicd.kubectl_manifest.ci_pipeline_run
resource "kubectl_manifest" "ci_pipeline_run" {
  depends_on = [random_uuid.ci_pipeline_run_uuid, gitea_repository.ok-gitea-repository, kubectl_manifest.git_clone_task]

  yaml_body = <<YAML
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: clone-read-run-${random_uuid.ci_pipeline_run_uuid.result}
  namespace: cicd
spec:
  pipelineRef:
    name: clone-read-and-push
  podTemplate:
    securityContext:
      fsGroup: 65532
  workspaces:
  - name: shared-data
    volumeClaimTemplate:
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
  - name: basic-auth
    secret:
      secretName: ${kubernetes_secret.git_credentials.metadata.0.name}
  - name: input
    persistentVolumeClaim:
      claimName: ${kubernetes_persistent_volume_claim.m3-demo-files.metadata.0.name}
  params:
  - name: repo-url
    value: http://gitea-http.infrastructure:3000/ok-user/ok-gitea-repository.git
YAML
}

resource "kubernetes_secret" "git_credentials" {
  metadata {
    name      = "basic-auth"
    namespace = "cicd"
  }

  data = {
    ".gitconfig"       = <<EOT
[credential "http://gitea-http.infrastructure:3000"]
  helper = store
EOT
    ".git-credentials" = "http://${gitea_user.ok-user.username}:${gitea_user.ok-user.password}@gitea-http.infrastructure:3000"
  }

  type = "Opaque"
}

resource "kubectl_manifest" "ci_show_readme_task" {
  depends_on = [gitea_repository.ok-gitea-repository]
  yaml_body  = file("${path.module}/tekton/show-readme-task.yaml")
}

resource "kubernetes_persistent_volume" "m3-demo-files" {
  metadata {
    name = "m3-demo-files-pv"
  }

  spec {
    capacity = {
      storage = "500Mi"
    }
    storage_class_name = "standard"
    access_modes       = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/m3-demo/"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "m3-demo-files" {
  metadata {
    name = "m3-demo-files-pvc"
    namespace = "cicd"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "500Mi"
      }
    }
    volume_name = kubernetes_persistent_volume.m3-demo-files.metadata.0.name
  }
}