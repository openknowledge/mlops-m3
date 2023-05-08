resource "kubectl_manifest" "ci_pipeline" {
  yaml_body = file("${path.module}/tekton/ci-pipeline.yaml")
}

resource "kubectl_manifest" "ci_build_pipeline" {
  yaml_body = file("${path.module}/tekton/ci-build-pipeline.yaml")
}

data "http" "git_clone_task" {
  url = "https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.6/git-clone.yaml"
}

data "http" "git_cli_task" {
  url = "https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-cli/0.4/git-cli.yaml"
}

data "http" "kaniko_task" {
  url = "https://raw.githubusercontent.com/tektoncd/catalog/main/task/kaniko/0.6/kaniko.yaml"
}

resource "kubectl_manifest" "git_cli_task" {
  override_namespace = kubernetes_namespace.cicd.metadata.0.name
  yaml_body          = data.http.git_cli_task.response_body
}

resource "kubectl_manifest" "git_clone_task" {
  override_namespace = kubernetes_namespace.cicd.metadata.0.name
  yaml_body          = data.http.git_clone_task.response_body
}

resource "kubectl_manifest" "kaniko_task" {
  override_namespace = kubernetes_namespace.cicd.metadata.0.name
  yaml_body          = data.http.kaniko_task.response_body
}

resource "kubectl_manifest" "cd_deploy_task" {
  override_namespace = kubernetes_namespace.cicd.metadata.0.name
  yaml_body          = file("${path.module}/tekton/cd-deploy-task.yaml")
}

resource "kubectl_manifest" "ci_pipeline_run" {
  depends_on = [
    kubectl_manifest.git_clone_task,
    kubectl_manifest.cd_deploy_task
  ]

  yaml_body = <<YAML
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: clone-read-run-initial
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
    value: http://gitea-http.infrastructure:3000/${var.gitea_user_name}/${var.gitea_repository_name}.git
  - name: git-user
    value: ${var.gitea_user_name}
  - name: git-user-email
    value: ${var.gitea_user_email}
YAML
}

resource "kubectl_manifest" "ci_pipeline_run_environment" {
  depends_on = [kubectl_manifest.git_clone_task, kubectl_manifest.ci_pipeline_run]

  yaml_body = <<YAML
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: clone-read-run-env
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
      claimName: ${kubernetes_persistent_volume_claim.m3-env-files.metadata.0.name}
  params:
  - name: repo-url
    value: http://gitea-http.infrastructure:3000/${var.gitea_user_name}/${var.gitea_env_repository_name}.git
  - name: git-user
    value: ${var.gitea_user_name}
  - name: git-user-email
    value: ${var.gitea_user_email}
YAML
}

resource "kubernetes_secret" "git_credentials" {
  metadata {
    name      = "basic-auth"
    namespace = kubernetes_namespace.cicd.metadata.0.name
  }

  data = {
    ".gitconfig"       = <<EOT
[credential "http://gitea-http.infrastructure:3000"]
  helper = store
EOT
    ".git-credentials" = "http://${var.gitea_user_name}:${var.gitea_password}@gitea-http.infrastructure:3000"
  }

  type = "Opaque"
}

resource "kubectl_manifest" "ci_show_readme_task" {
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
    namespace = kubernetes_namespace.cicd.metadata.0.name
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

resource "kubernetes_persistent_volume" "m3-env-files" {
  metadata {
    name = "m3-env-files-pv"
  }

  spec {
    capacity = {
      storage = "500Mi"
    }
    storage_class_name = "standard"
    access_modes       = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/m3-env/"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "m3-env-files" {
  metadata {
    name = "m3-env-files-pvc"
    namespace = kubernetes_namespace.cicd.metadata.0.name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "500Mi"
      }
    }
    volume_name = kubernetes_persistent_volume.m3-env-files.metadata.0.name
  }
}

resource "kubectl_manifest" "commit_trigger_template" {
  yaml_body = <<YAML
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerTemplate
metadata:
  name: ci-triggertemplate
  namespace: ${kubernetes_namespace.cicd.metadata.0.name}
spec:
  params:
    - name: gitrevision
      description: The git revision
      default: main
    - name: gitrepositoryurl
      description: The git repository url
    - name: envgitrepositoryurl
      description: The git repository url of the env repo
    - name: namespace
      description: The namespace to create the resources
      default: ${kubernetes_namespace.cicd.metadata.0.name}
    - name: imagereference
      description: The image reference to use
      default: localhost:5001/insurance-prediction
    - name: stage
      description: The stage that will be deployed to
      default: kind
    - name: path-to-patch-file
      description: The path to the patch file
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: commit-triggered-run-
        namespace: $(tt.params.namespace)
      spec:
        serviceAccountName: ${kubernetes_service_account_v1.m3_build_sa.metadata.0.name}
        pipelineRef:
          name: clone-read-and-build
        podTemplate:
          securityContext:
            fsGroup: 65532
        params:
        - name: repo-url
          value: $(tt.params.gitrepositoryurl)
        - name: env-repo-url
          value: $(tt.params.envgitrepositoryurl)
        - name: image-reference
          value: $(tt.params.imagereference)
        - name: stage
          value: $(tt.params.stage)
        - name: path-to-patch-file
          value: $(tt.params.path-to-patch-file)
        workspaces:
        - name: shared-data
          volumeClaimTemplate:
            spec:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 1Gi
        - name: env-repo
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
YAML
}

resource "kubectl_manifest" "event_listener" {
  yaml_body = <<YAML
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: ci-listener
  namespace: cicd
spec:
  serviceAccountName: m3-sa
  triggers:
    - bindings:
        - ref: ci-pipelinebinding
      template:
        ref: ci-triggertemplate

YAML
}

resource "kubectl_manifest" "trigger_binding" {
  yaml_body = <<YAML
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  name: ci-pipelinebinding
  namespace: cicd
spec:
  params:
    - name: gitrevision
      value: $(body.head_commit.id)
    - name: namespace
      value: cicd
    - name: gitrepositoryurl
      value: "http://gitea-http.infrastructure:3000/$(body.repository.full_name)"
    - name: envgitrepositoryurl
      value: "http://gitea-http.infrastructure:3000/${var.gitea_user_name}/${var.gitea_env_repository_name}.git"
    - name: imagereference
      value: "insurance-prediction:$(body.head_commit.id)"
    - name: path-to-patch-file
      value: "patches/version-patch.yaml"
YAML
}
