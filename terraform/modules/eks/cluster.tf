/**
 * EKSクラスター関連のリソース
 */

# EKSクラスター
resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    security_group_ids      = [var.eks_security_group_id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
    aws_cloudwatch_log_group.eks
  ]

  tags = local.tags
}

# EKSクラスターのCloudWatchロググループ
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = 7
  tags              = local.tags
}

# EKS OIDCプロバイダー
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = local.tags
}

# EKSクラスターのTLS証明書
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# kubeconfig生成
resource "local_file" "kubeconfig" {
  content = templatefile("${path.module}/templates/kubeconfig.tpl", {
    cluster_name     = aws_eks_cluster.main.name
    cluster_endpoint = aws_eks_cluster.main.endpoint
    cluster_ca_data  = aws_eks_cluster.main.certificate_authority[0].data
    region           = var.region
  })
  filename = "${path.module}/kubeconfig"
}