provider "aws" {
  region = "us-west-2" # Replace with your AWS region
}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}

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
