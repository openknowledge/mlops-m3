resource "kubernetes_role_binding_v1" "m3-sa" {
  metadata {
    name      = "m3-trigger-eventlistener-binding"
    namespace = kubernetes_namespace.cicd.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "tekton-triggers-eventlistener-roles"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "m3-sa"
    namespace = kubernetes_namespace.cicd.metadata.0.name
    api_group = "" #TODO ugly
  }
}

resource "kubernetes_cluster_role_binding_v1" "m3-sa" {
  metadata {
    name = "m3-trigger-eventlistener-cluster-binding"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "tekton-triggers-eventlistener-clusterroles"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "m3-sa"
    namespace = kubernetes_namespace.cicd.metadata.0.name
    api_group = ""
  }
}

resource "kubernetes_service_account_v1" "m3-sa" {
  metadata {
    name = "m3-sa"
    namespace = kubernetes_namespace.cicd.metadata.0.name
  }
  secret {
    name = kubernetes_secret_v1.m3-sa.metadata.0.name
  }
}

resource "kubernetes_secret_v1" "m3-sa" {
  metadata {
    name = "m3-sa"
    namespace = kubernetes_namespace.cicd.metadata.0.name
  }
}
