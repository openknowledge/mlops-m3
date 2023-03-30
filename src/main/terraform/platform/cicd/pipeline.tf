resource "kubectl_manifest" "ci_pipeline" {
  yaml_body = <<YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: clone-read
  namespace: cicd
spec:
  description: |
    This pipeline clones a git repo, then echoes the README file to the stdout.
  params:
  - name: repo-url
    type: string
    description: The git repo URL to clone from.
  workspaces:
  - name: shared-data
    description: |
      This workspace contains the cloned repo files, so they can be read by the
      next task.
  - name: basic-auth
    description: |
      This workspace contains the basic-auth for gitea
  tasks:
  - name: fetch-source
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: shared-data
    - name: basic-auth
      workspace: basic-auth
    params:
    - name: url
      value: $(params.repo-url)
  - name: show-readme
    runAfter: ["fetch-source"]
    taskRef:
      name: show-readme
    workspaces:
    - name: source
      workspace: shared-data
YAML
}

data "http" "git_clone_task" {
  url = "https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.6/git-clone.yaml"
}

resource "kubectl_manifest" "git_clone_task" {
  override_namespace = kubernetes_namespace.cicd.metadata.0.name
  yaml_body = data.http.git_clone_task.response_body
}

resource "random_id" "ci_pipeline_run_id" {
  byte_length = 8
}

resource "kubectl_manifest" "ci_pipeline_run" {
  depends_on = [gitea_repository.ok-gitea-repository, kubectl_manifest.git_clone_task]
  yaml_body = <<YAML
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: clone-read-run-${random_id.ci_pipeline_run_id.hex}
  namespace: cicd
spec:
  pipelineRef:
    name: clone-read
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
  params:
  - name: repo-url
    value: http://gitea.local/ok-user/ok-gitea-repository.git
YAML
}

resource "kubernetes_secret" "git_credentials" {
  metadata {
    name = "basic-auth"
    namespace = "cicd"
  }

  data = {
    ".gitconfig" = <<EOT
[credential "https://gitea.local"]
  helper = store
EOT
    ".git-credentials" = "http://${gitea_user.ok-user.username}:${gitea_user.ok-user.password}@gitea.local"
  }

  type = "Opaque"
}

resource "kubectl_manifest" "ci_show_readme_task" {
  depends_on = [gitea_repository.ok-gitea-repository]
  yaml_body = <<YAML
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: show-readme
  namespace: cicd
spec:
  description: Read and display README file.
  workspaces:
  - name: source
  steps:
  - name: read
    image: alpine:latest
    script: |
      #!/usr/bin/env sh
      cat $(workspaces.source.path)/README.md
YAML
}