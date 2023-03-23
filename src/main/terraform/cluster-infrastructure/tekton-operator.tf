data "http" "tekton_operator_release" {
  url = "https://storage.googleapis.com/tekton-releases/operator/previous/v0.64.0/release.yaml"
}

data "kubectl_file_documents" "tekton_operator_release" {
  content = data.http.tekton_operator_release.response_body
}

resource "kubectl_manifest" "tekton_operator" {
  for_each = data.kubectl_file_documents.tekton_operator_release.manifests
  yaml_body = each.value
}