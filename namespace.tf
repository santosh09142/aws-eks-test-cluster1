



data "local_file" "namespaces" {
  filename = "${path.module}/namespaces.txt"
}

locals {
  namespace_list = [for ns in split("\n", trimspace(data.local_file.namespaces.content)) : trimspace(ns)]
}

resource "kubernetes_namespace" "namespace" {
  for_each = toset(local.namespace_list)

  metadata {
    name = each.value
  }
}

resource "kubernetes_role" "role" {
  for_each = toset(local.namespace_list)

  metadata {
    name      = "${each.value}-role"
    namespace = each.value
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "deployments"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
  }
}

resource "kubernetes_role_binding" "rolebinding" {
  for_each = toset(local.namespace_list)

  metadata {
    name      = "${each.value}-rolebinding"
    namespace = each.value
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.role[each.key].metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "${each.value}-grp"
    api_group = "rbac.authorization.k8s.io"
  }
}
