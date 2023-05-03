resource "kubernetes_role_binding_v1" "m3_sa" {
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

resource "kubernetes_cluster_role_binding_v1" "m3_sa" {
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

resource "kubernetes_service_account_v1" "m3_sa" {
  metadata {
    name = "m3-sa"
    namespace = kubernetes_namespace.cicd.metadata.0.name
  }
  secret {
    name = kubernetes_secret_v1.m3_sa.metadata.0.name
  }
}

resource "kubernetes_secret_v1" "m3_sa" {
  metadata {
    name = "m3-sa"
    namespace = kubernetes_namespace.cicd.metadata.0.name
  }
}

resource "kubernetes_service_account_v1" "m3_build_sa" {
  metadata {
    name = "m3-build-sa"
    namespace = kubernetes_namespace.cicd.metadata.0.name
  }
  secret {
    name = kubernetes_secret_v1.m3_build_sa.metadata.0.name
  }
}

resource "kubernetes_secret_v1" "m3_build_sa" {
  metadata {
    name = "m3-build-sa"
    namespace = kubernetes_namespace.cicd.metadata.0.name
  }
}

resource "kubernetes_role_binding_v1" "m3_build_sa" {
  metadata {
    name      = "m3-build-role-binding"
    namespace = kubernetes_namespace.cicd.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.app_deployer.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.m3_build_sa.metadata.0.name
    namespace = kubernetes_namespace.cicd.metadata.0.name
    api_group = "" #TODO ugly
  }
}

resource "kubernetes_cluster_role_binding_v1" "m3_build_sa" {
  metadata {
    name = "m3-build-cluster-binding"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.app_deployer.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.m3_build_sa.metadata.0.name
    namespace = kubernetes_namespace.cicd.metadata.0.name
    api_group = ""
  }
}

resource "kubernetes_cluster_role_v1" "app_deployer" {
  metadata {
    name = "app-deployer"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "services"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}