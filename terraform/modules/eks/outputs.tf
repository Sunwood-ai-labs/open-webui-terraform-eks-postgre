output "cluster_id" {
  description = "EKSクラスターのID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKSクラスターの名前"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKSクラスターのエンドポイント"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "EKSクラスターのセキュリティグループID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "kubeconfig_path" {
  description = "kubeconfigファイルのパス"
  value       = local_file.kubeconfig.filename
}

output "oidc_provider_arn" {
  description = "EKS OIDCプロバイダーのARN"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "node_group_id" {
  description = "EKSノードグループのID"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "EKSノードグループのARN"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "EKSノードグループのステータス"
  value       = aws_eks_node_group.main.status
}
